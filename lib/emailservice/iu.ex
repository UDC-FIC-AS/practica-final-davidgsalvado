defmodule Ui do

  use Agent

  def init_ui(dir_node) do
    conx = Client.init(dir_node)
    case conx do
      {:ok, dir_node} ->
        Agent.start_link(fn -> "" end, name: :username, timeout: :infinity)
        prompt_1(dir_node)
      {:error, :connection_error} -> Prompt.display("conextion error : try again later")
    end
  end

  def send_req_user(dir_node, req) do
    Client.send_request(dir_node, {:user_lbs, req}, true)
  end

  def send_req_mess(dir_node, req) do
    Client.send_request(dir_node, {:message_lbs, req}, true)
  end

  def prompt_1(dir_node) do
    cmd = Prompt.text(">")
    splited_cmd = String.split(cmd, " ", trim: true)
    if Enum.count(splited_cmd) == 0 do
      prompt_1(dir_node)
    else
      [action | _] = splited_cmd

      case action do
        "register" ->
          if Enum.count(splited_cmd) >= 3 do
            Agent.update(:username, fn _ -> Enum.at(splited_cmd, 1) end)
            send_req_user(dir_node, {:register, {Enum.at(splited_cmd, 1), Enum.at(splited_cmd, 2)}})
          else
            Prompt.display("incorrect format : register [username] [password]")
            prompt_1(dir_node)
          end
        "login" ->
          if Enum.count(splited_cmd) >= 3 do
            Agent.update(:username, fn _ -> Enum.at(splited_cmd, 1) end)
            send_req_user(dir_node, {:login, {Enum.at(splited_cmd, 1), Enum.at(splited_cmd, 2)}})
          else
            Prompt.display("incorrect format : login [username] [password]")
            prompt_1(dir_node)
          end
        "help" ->
          print_help(dir_node, 1)
        _ ->
          Prompt.display("invalid command")
          prompt_1(dir_node)
      end
    end
  end

  defp prompt_2(dir_node) do
    cmd = Prompt.text(">")
    splited_cmd = String.split(cmd, " ", trim: true)
    if Enum.count(splited_cmd) == 0 do
      prompt_2(dir_node)
    else
      [action | _] = splited_cmd

      user = Agent.get(:username, fn state -> state end, :infinity)

      case action do
        "list_users" ->
          send_req_user(dir_node, {:list_users, nil})
        "send" ->
          if Enum.count(splited_cmd) >= 3 do
            send_req_mess(dir_node, {:send_message, {{user, Enum.at(splited_cmd, 1)}, Enum.at(splited_cmd, 2)}})
          else
            Prompt.display("incorrect format : send [recipient] [message]")
            prompt_2(dir_node)
          end
        "unseen_mess" ->
          send_req_mess(dir_node, {:read_unseen, user})
        "all_mess" ->
          send_req_mess(dir_node, {:read_all, user})
        "del_read_mess" ->
          send_req_mess(dir_node, {:delete_seen, user})
        "logout" -> :ok
        _ ->
          Prompt.display("invalid command")
          prompt_2(dir_node)
      end
    end
  end


  def receive_response(dir_node) do
    receive do
      {:ok, {:register, :registered_succesfully}} ->
        Prompt.display("user registered succesfully!")
        prompt_2(dir_node)
      {:error, :user_already_registered} ->
        Prompt.display("username already taken :")
        prompt_1(dir_node)
      {:error, :wrong_password} ->
        Prompt.display("unsuccessful login")
        prompt_1(dir_node)
      {:error, :user_does_not_exist} ->
        Prompt.display("unsuccessful login")
        prompt_1(dir_node)
      {:ok, {:login, :correct_password}} ->
        Prompt.display("welcome!")
        prompt_2(dir_node)
      {:ok, {:list_users, name_list}} ->
        Prompt.display(Enum.join(name_list, "\n"))
        prompt_2(dir_node)
      {:error, {:send_message, :user_does_not_exist}} ->
        Prompt.display("recipient does not exist")
        prompt_2(dir_node)
      {:ok, {:send_message, :messsage_sent_succesfully}} ->
        Prompt.display("messsage sent succesfully")
        prompt_2(dir_node)
      {:error, {:read_unseen, :user_does_not_exist}} ->
        Prompt.display("There are not unread messages")
        prompt_2(dir_node)
      {:ok, {:read_unseen, unseen_m_l}} ->
        Prompt.table([["From:", "Message:"] | Enum.map(unseen_m_l, fn e -> Enum.to_list(e) end)], header: true)
        prompt_2(dir_node)
      {:error, {:read_all, :user_does_not_exist}} ->
        Prompt.display("There are not any messages")
        prompt_2(dir_node)
      {:ok, {:read_all, all_m_l}} ->
        Prompt.table([["From:", "Message:"] | Enum.map(all_m_l, fn e -> Enum.to_list(e) end)], header: true)
        prompt_2(dir_node)
      {:ok, {:delete_seen, :deleted_succesfully}} ->
        Prompt.display("Readed messages deleted successfully")
        prompt_2(dir_node)
      {:error, _} ->
        Prompt.display("conextion error : try again later")
    end
  end

  def print_help_aux() do
    Prompt.display("register [username] [password]\nlogin [usernnme] [password]\nlogout\nlist_users\nsend [username] [message]\nnew_messages\nall_messages\ndelete_read_messages\n")
  end

  def print_help(dir_node, type) do
    print_help_aux()
    case type do
      1 -> prompt_1(dir_node)
      2 -> prompt_2(dir_node)
    end
  end
end