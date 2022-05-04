defmodule NodeManager do

  def init(agent_name) do
    Agent.start_link(
    fn ->
      []
    end,
    name: agent_name,
    timeout: :infinity)
  end

  def add(agent_name, node) do
    if Node.connect(node) do
      Agent.update(agent_name,
      fn node_list ->
        [node | node_list]
      end, :infinity)

      {:ok, node}
    else
      {:error, :connection_error}
    end
  end

  def remove(agent_name, node) do
    Agent.update(agent_name,
    fn node_list ->
      aux_remove(node_list, node)
    end, :infinity)
  end

  defp aux_remove([], _), do: []
  defp aux_remove(node_list, node) do
    List.delete(node_list, node)
  end

  def get(agent_name) do
    Agent.get_and_update(agent_name,
    fn node_list ->
      aux_get(node_list)
    end, :infinity)
  end

  defp aux_get([]), do: {[], []}
  defp aux_get([node | node_list]) do
    {node, node_list ++ [node]}
 end

end
