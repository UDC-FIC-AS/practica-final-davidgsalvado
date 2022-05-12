defmodule Ui do

  use Agent

  #Lanzar nodo cliente y ejecutar Ui.init_ui(:"dir@[IP]")

  def init_ui(dir_node) do
    conx = Client.init(dir_node)
    case conx do
      {:ok, dir_node} ->
        Agent.start_link(fn -> "" end, name: :username, timeout: :infinity)
        Agent.start_link(fn -> 1 end, name: :is_in, timeout: :infinity)
        prompt_1(dir_node)
      {:error, :connection_error} -> Prompt.display("connection error : try again later")
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp send_req_user(dir_node, req) do
    Client.send_request(dir_node, {:user_lbs, req}, true)
  end

  defp send_req_mess(dir_node, req) do
    Client.send_request(dir_node, {:message_lbs, req}, true)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp tuple_to_list({sender, message}) do
    [sender | [message | []]]
  end

  defp get_message_to_send(l) do
    [_ | t] = l
    [_ | message] = t
    Enum.join(message, " ")
  end

  defp display_aux(dir_node, text, type) do
    Process.sleep(200) #Sleep para evitar problemas con en compilador interactivo.
    Prompt.display(text)
    case type do
      1 -> prompt_1(dir_node)
      2 -> prompt_2(dir_node)
    end
  end

  defp print_help_aux() do
    Prompt.display("register [username] [password]\nlogin [username] [password]\nexit\nlist_users\nsend [username] [message]\nnew_messages\nall_messages\ndelete_read_messages\n")
  end

  defp print_help(dir_node, type) do
    print_help_aux()
    case type do
      1 -> prompt_1(dir_node)
      2 -> prompt_2(dir_node)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp prompt_1(dir_node) do
    Process.sleep(50)
    cmd = Prompt.text(">")
    splitted_cmd = String.split(cmd, " ", trim: true)
    if Enum.count(splitted_cmd) == 0 do
      prompt_1(dir_node)
    else
      [action | _] = splitted_cmd

      case action do
        "register" ->
          if Enum.count(splitted_cmd) >= 3 do
            Agent.update(:username, fn _ -> Enum.at(splitted_cmd, 1) end)
            send_req_user(dir_node, {:register, {Enum.at(splitted_cmd, 1), Enum.at(splitted_cmd, 2)}})
          else
            Prompt.display("incorrect format : register [username] [password]")
            prompt_1(dir_node)
          end
        "login" ->
          if Enum.count(splitted_cmd) >= 3 do
            Agent.update(:username, fn _ -> Enum.at(splitted_cmd, 1) end)
            send_req_user(dir_node, {:login, {Enum.at(splitted_cmd, 1), Enum.at(splitted_cmd, 2)}})
          else
            Prompt.display("incorrect format : login [username] [password]")
            prompt_1(dir_node)
          end
        "exit" ->
          Process.exit(self(), :kill)
        "help" ->
          print_help(dir_node, 1)
        _ ->
          Prompt.display("invalid command")
          prompt_1(dir_node)
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  defp prompt_2(dir_node) do
    cmd = Prompt.text(">")
    splitted_cmd = String.split(cmd, " ", trim: true)
    if Enum.count(splitted_cmd) == 0 do
      prompt_2(dir_node)
    else
      [action | _] = splitted_cmd

      user = Agent.get(:username, fn state -> state end, :infinity)

      case action do
        "list_users" ->
          send_req_user(dir_node, {:list_users, nil})
        "send" ->
          if Enum.count(splitted_cmd) >= 3 do
            message = get_message_to_send(splitted_cmd)
            send_req_mess(dir_node, {:send_message, {{user, Enum.at(splitted_cmd, 1)}, message}})
          else
            Prompt.display("incorrect format : send [recipient] [message]")
            prompt_2(dir_node)
          end
        "new_messages" ->
          send_req_mess(dir_node, {:read_unseen, user})
        "all_messages" ->
          send_req_mess(dir_node, {:read_all, user})
        "delete_read_messages" ->
          send_req_mess(dir_node, {:delete_seen, user})
        "exit" ->
          Process.exit(self(), :kill)
        "help" -> print_help(dir_node, 2)
        _ ->
          Prompt.display("invalid command")
          prompt_2(dir_node)
      end
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def receive_response(dir_node) do
    receive do
      {:ok, {:register, :registered_succesfully}} ->
        Agent.update(:is_in, fn _ -> 2 end)
        display_aux(dir_node, "registered succesfully! :)", 2)
      {:ok, {:login, :correct_password}} ->
        Agent.update(:is_in, fn _ -> 2 end)
        display_aux(dir_node, "welcome!", 2)
      {:error, :user_already_registered} ->
        display_aux(dir_node, "username already taken :(", 1)
      {:error, :wrong_password} ->
        display_aux(dir_node, "unsuccessful login", 1)
      {:error, :user_does_not_exist} ->
        display_aux(dir_node, "unsuccessful login", 1)
      {:ok, {:list_users, name_list}} ->
        display_aux(dir_node, Enum.join(name_list, "\n"), 2)
      {:error, {:send_message, :user_does_not_exist}} ->
        display_aux(dir_node, "recipient does not exist", 2)
        prompt_2(dir_node)
      {:ok, {:send_message, :messsage_sent_succesfully}} ->
        display_aux(dir_node, "message sent successfully", 2)
        prompt_2(dir_node)
      {:ok, {:read_unseen, unseen_m_l}} ->
        Process.sleep(500)
        Prompt.table([["From:", "Message:"] | Enum.map(unseen_m_l, fn e -> tuple_to_list(e) end)], header: true)
        prompt_2(dir_node)
      {:error, {:read_all, :user_does_not_exist}} ->
        display_aux(dir_node, "There are not any messages", 2)
        prompt_2(dir_node)
      {:ok, {:read_all, all_m_l}} ->
        Process.sleep(500)
        Prompt.table([["From:", "Message:"] | Enum.map(all_m_l, fn e -> tuple_to_list(e) end)], header: true)
        prompt_2(dir_node)
      {:ok, {:delete_seen, :deleted_succesfully}} ->
        display_aux(dir_node, "Read messages deleted successfully", 2)
      {:error, _} ->
        is_in = Agent.get(:is_in, fn state -> state end)
        display_aux(dir_node, "connection error : try again later", is_in)
    end
  end

end
