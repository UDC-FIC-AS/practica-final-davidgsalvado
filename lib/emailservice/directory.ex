defmodule Directory do

  def init do
    NodeManager.init(:user_lbs)
    NodeManager.init(:message_lbs)
  end

  def add(lb_type, lb_node) do
    NodeManager.add(lb_type, lb_node)
  end

  def remove(lb_type, lb_node) do
    NodeManager.remove(lb_type, lb_node)
  end

  def receive_request(client_rec_pid) do
    receive do
      {lb_type, action} ->
        try do
          distribute(client_rec_pid, {lb_type, action})
        rescue
          _ -> send(client_rec_pid, {:error, :load_balancer_connection_error})
        end
    end
  end

  defp distribute(client_rec_pid, {lb_type, action}) do
    lb_node = NodeManager.get(lb_type)

    dir_rec_pid = spawn(fn -> receive_response(client_rec_pid) end)

    ConnectionManager.check_node_connection(lb_node)

    lb_rec_pid = Node.spawn_link(lb_node,
    fn ->
      LoadBalancer.receive_request(dir_rec_pid)
    end)

    send(lb_rec_pid, {lb_type, action})
  end

  defp receive_response(client_rec_pid) do
    receive do
      {status, content} ->
        send(client_rec_pid, {status, content})
    end
  end

end
