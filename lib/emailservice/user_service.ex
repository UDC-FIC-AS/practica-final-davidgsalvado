defmodule UserService do

  def init_user_service do
    NodeManager.init(:user_db)
    NodeManager.init(:message_db)
  end

  def add_user_db(db_node) do
    NodeManager.add(:user_db, db_node)
  end

  def add_message_db(db_node) do
    NodeManager.add(:message_db, db_node)
  end

  def receive_request(dir_rec_pid) do
    receive do
      {action, args} ->
        try do
          execute_action({action, args}, dir_rec_pid)
        catch
          _ -> send(dir_rec_pid, {:error, :db_connection_error})
        end
    end
  end

  defp execute_action({:register, {username, password}}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.read({:global, :user_db}, username)

    case resp do
      {:error, :not_found} ->
        ConnectionManager.check_db_connection(:user_db)
        ServerDb.write({:global, :user_db}, username, password)
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.write({:global, :message_db}, username, [])
        send(dir_rec_pid, {:ok, {:register, :registered_succesfully}})

      _ -> send(dir_rec_pid, {:error, :user_already_registered})
    end
  end

  defp execute_action({:login, {username, password}}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.read({:global, :user_db}, username)

    case resp do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, :user_does_not_exist})
      {:ok, pass} ->
        if password == pass do
          send(dir_rec_pid, {:ok, {:login, :correct_password}})
        else
          send(dir_rec_pid, {:error, :wrong_password})
        end
    end
  end

  defp execute_action({:list_users, _}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.get_all_content({:global, :user_db})
    name_list = filter_names(resp, [])
    send(dir_rec_pid, {:ok, {:list_users, name_list}})
  end

  defp filter_names([], name_list), do: name_list
  defp filter_names([{username, _} | t], name_list) do
    filter_names(t, [username | name_list])
  end

end
