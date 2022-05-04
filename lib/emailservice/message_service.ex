defmodule MessageService do
  def receive_request(dir_rec_pid) do
    receive do
      {action, args} -> execute_action({action, args}, dir_rec_pid)
    end
  end

  def execute_action({:send_message, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "send_message"})
  end

  def execute_action({:read_unseen, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "read_unseen"})
  end

  def execute_action({:read_all, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "read_all"})
  end

  def execute_action({:delete_read, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "delete_read"})
  end

end
