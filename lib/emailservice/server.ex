defmodule Server do
  use Agent
  #============================[SERVER FUNCTIONS]==============================#
  def init_server() do
    start_user_agent([])
  end

  def do_register(username, password) do
    user_service_node = get_user_service()
    Node.spawn_link(user_service_node,
    fn ->
      ServiceUsers.register(username, password)
    end)
  end

#____________________________[USER SERVICE AGENT]______________________________#

  defp start_user_agent(initial_value) do
    Agent.start_link(
    fn -> initial_value end,
    name: :user_agent,
    timeout: :infinity)
  end

  def add_user_service(user_service_node) do
    if Node.connect(user_service_node) do
      Agent.update(:user_agent,
      fn user_service_list ->
        [user_service_node | user_service_list]
      end, :infinity)

      {:ok, user_service_node}
    else
      {:error, :connection_error}
    end
  end

  def delete_user_service(to_del_node) do
    Agent.update(:user_agent,
    fn user_service_list ->
      aux_delete_user_service(user_service_list, to_del_node)
    end, :infinity)
  end

  defp aux_delete_user_service([], _), do: []
  defp aux_delete_user_service(user_service_list, to_del_node) do
    List.delete(user_service_list, to_del_node)
  end

  def get_user_service() do
    Agent.get_and_update(:user_agent,
    fn user_service_list ->
      aux_get_user_service(user_service_list)
    end, :infinity)
  end

  defp aux_get_user_service([]), do: {[], []}
  defp aux_get_user_service([user_service_node | t]) do
    {user_service_node, t ++ [user_service_node]}
 end

end
