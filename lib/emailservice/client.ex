defmodule Client do

  def init(dir_ip) do
    dir_node = Utilities.get_node("dir", dir_ip)
    if Node.connect(dir_node) do {:ok, dir_node}
    else {:error, :connection_error} end
  end

  def send_request(dir_node, request, true) do
    rec_pid = spawn(fn -> Ui.receive_response(dir_node) end)
    send_request_aux(dir_node, request, rec_pid) #TODO poner en try do
    :ok
  end

  def send_request(dir_node, request, false) do
    rec_pid = spawn(fn -> receive_response() end)
    send_request_aux(dir_node, request, rec_pid)
    :ok
  end

  def send_request_aux(dir_node, request, rec_pid) do
    dir_pid = Node.spawn_link(dir_node,
      fn ->
        Directory.receive_request(rec_pid)
      end)

    send(dir_pid, request)
  end

  defp receive_response() do
    receive do
      {:ok, resp} -> IO.inspect resp
      {:error, error} -> IO.inspect error
    end
  end

end
