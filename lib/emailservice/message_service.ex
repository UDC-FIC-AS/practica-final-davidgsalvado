defmodule MessageService do

  def init_message_service do
    NodeManager.init(:message_db)
  end

  def add_db(db_node) do
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

  defp execute_action({:send_message, {{sender, recipient}, message}}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:message_db)
    resp_read = ServerDb.read({:global, :message_db}, recipient)

    case resp_read do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, {:send_message, :user_does_not_exist}})
      {:ok, message_list} ->
        new_message_list = [{sender, {message, false}} | message_list]
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.overwrite({:global, :message_db}, recipient, new_message_list)
        send(dir_rec_pid, {:ok, {:send_message, :messsage_sent_succesfully}})
    end

  end

  defp execute_action({:read_unseen, username}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:message_db)
    resp_read = ServerDb.read({:global, :message_db}, username)

    case resp_read do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, {:read_unseen, :user_does_not_exist}})
      {:ok, message_list} ->
        {marked_m_l, unseen_m_l, _} = mark_and_get(message_list, [], [], [])
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.overwrite({:global, :message_db}, username, marked_m_l)
        send(dir_rec_pid, {:ok, {:read_unseen, unseen_m_l}})
    end

  end

  defp execute_action({:read_all, username}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:message_db)
    resp_read = ServerDb.read({:global, :message_db}, username)

    case resp_read do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, {:read_all, :user_does_not_exist}})
      {:ok, message_list} ->
        {marked_m_l, _, all_m_l} = mark_and_get(message_list, [], [], [])
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.overwrite({:global, :message_db}, username, marked_m_l)
        send(dir_rec_pid, {:ok, {:read_all, all_m_l}})
    end

  end

  defp execute_action({:delete_seen, username}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:message_db)
    resp_read = ServerDb.read({:global, :message_db}, username)

    case resp_read do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, {:delete_seen, :user_does_not_exist}})
      {:ok, message_list} ->
        unseen_db_m_l = delete_seen(message_list, [])
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.overwrite({:global, :message_db}, username, unseen_db_m_l)
        send(dir_rec_pid, {:ok, {:delete_seen, :deleted_succesfully}})
    end

  end

  defp mark_and_get([], marked_m_l, unseen_m_l, all_m_l) do
    {marked_m_l, unseen_m_l, all_m_l}
  end

  defp mark_and_get([{sender, {message, true}} | t], marked_m_l, unseen_m_l, all_m_l) do
      mark_and_get(
      t,
      [{sender, {message, true}} | marked_m_l],
      unseen_m_l,
      [{sender, message} | all_m_l]
      )
  end

  defp mark_and_get([{sender, {message, false}} | t], marked_m_l, unseen_m_l, all_m_l) do
      mark_and_get(
      t,
      [{sender, {message, true}} | marked_m_l],
      [{sender, message} | unseen_m_l],
      [{sender, message} | all_m_l]
      )
  end

  defp delete_seen([], unseen_db_m_l), do: unseen_db_m_l

  defp delete_seen([{_, {_, true}} | t], unseen_db_m_l) do
    delete_seen(
    t,
    unseen_db_m_l
    )
  end

  defp delete_seen([{sender, {message, false}} | t], unseen_db_m_l) do
    delete_seen(
    t,
    [{sender, {message, false}} | unseen_db_m_l]
    )
  end

end
