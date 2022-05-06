defmodule Client do

  def init(dir_node) do
    if Node.connect(dir_node) do {:ok, dir_node}
    else {:error, :connection_error} end
  end

  def send_request(dir_node, request) do
    client_rec_pid = spawn(fn -> receive_response() end)

    dir_pid = Node.spawn_link(dir_node,
    fn ->
      Directory.receive_request(client_rec_pid)
    end)

    send(dir_pid, request)
  end

  def receive_response() do
    receive do
      {:ok, resp} -> IO.inspect resp
      {:error, error} -> IO.inspect error
    end
  end

end
