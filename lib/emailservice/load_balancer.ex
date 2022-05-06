defmodule LoadBalancer do

  def init(sv_type) do
    NodeManager.init(sv_type)
  end

  def add_service(sv_type, sv_node) do
    NodeManager.add(sv_type, sv_node)
  end

  def remove_service(sv_type, sv_node) do
    NodeManager.remove(sv_type, sv_node)
  end

  def receive_request(dir_rec_pid) do
    receive do
      {lb_type, {action, args}} ->
        try do
          process_action(lb_type, {action, args}, dir_rec_pid)
        rescue
          _ -> send(dir_rec_pid, {:error, :service_connection_error})
        end
      end
  end

  def process_action(sv_type, {action, args}, dir_rec_pid) do
    sv_node = NodeManager.get(sv_type)
    service_rec_pid = Node.spawn_link(sv_node,
    fn ->
      case sv_type do
        :user_lbs -> UserService.receive_request(dir_rec_pid)
        :message_lbs -> MessageService.receive_request(dir_rec_pid)
      end
    end)

    send(service_rec_pid, {action, args})
  end

end
