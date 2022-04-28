defmodule Client do

  def init_client(server_ip) do
    server_node = ["server@", server_ip] |> Enum.join("") |> String.to_atom

    if Node.connect(server_node) do {:ok, server_node}
    else {:error, :connection_error} end
  end

  def register(server_node, username, password) do
    Node.spawn_link(server_node,
    fn ->
      Server.do_register(username, password)
    end)
  end

end
