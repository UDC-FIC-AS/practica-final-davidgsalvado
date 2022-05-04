defmodule UserService do
  def receive_request(dir_rec_pid) do
    receive do
      {action, args} ->
        execute_action({action, args}, dir_rec_pid)
    end
  end

  def execute_action({:register, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "register"})
  end

  def execute_action({:login, args}, dir_rec_pid) do
    #TODO implement actions
    send(dir_rec_pid, {:ok, "login"})
  end

end
