defmodule NodeManager do
  @moduledoc """
  Módulo que implementa un gestor de nodos.

  Este módulo tiene como finalidad ofrecer una forma sencilla de gestionar una
  lista de nodos con operaciones como add, remove y get.

  En este caso la función get implementa la técnica "RoundRobin de paso uno". Es
  importante destacar que este comportamiento no ofrece resultados para listas
  de uno solo elemento. Este caso lo empleamos para almacenar las
  direcciones de los nodos de las bases de datos en los servicios.

  Implementado con Agent para poder almacenar y modificar el estado de la lista.
  """

  @doc """
  Inicializa la lista de nodos.

  ## Parámetros

    - agent_name : Átomo que identifica la lista creada.

  ## Ejemplos
      iex> NodeManager.init(:prueba)
      :ok
      iex> Process.whereis(:prueba) |> Process.alive?
      true
      iex> Agent.stop(:prueba)
      :ok
  """
  @spec init(atom()) :: :ok
  def init(agent_name) do
    Agent.start_link(
    fn ->
      []
    end,
    name: agent_name,
    timeout: :infinity)
    :ok
  end

  @doc """
  Añade un nodo a la lista.

  ## Parámetros

    - agent_name : Átomo que identifica la lista.
    - node: Nodo a incluir en la lista.

  ## Ejemplos
      iex> NodeManager.init(:prueba)
      iex> NodeManager.add(:prueba, :"no_existe@192.168.1.134")
      {:error, :connection_error}
      iex> node = Node.self()
      iex> NodeManager.add(:prueba, node)
      {:ok, node}
      iex> Agent.stop(:prueba)
  """
  @spec add(atom(), node()) :: {:ok, node()} | {:error, :connection_error}
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

  @doc """
  Elimina un nodo de la lista.

  ## Parámetros

    - agent_name : Átomo que identifica la lista creada.
    - node: Nodo a eliminar de la lista.

  ## Ejemplos
      iex> NodeManager.init(:prueba)
      iex> node = Node.self()
      iex> NodeManager.add(:prueba, node)
      iex> NodeManager.remove(:prueba, node)
      :ok
      iex> Agent.stop(:prueba)
  """
  @spec remove(atom(), node()) :: :ok
  def remove(agent_name, node) do
    Agent.update(agent_name,
    fn node_list ->
      aux_remove(node_list, node)
    end, :infinity)
    :ok
  end

  defp aux_remove([], _), do: []
  defp aux_remove(node_list, node) do
    List.delete(node_list, node)
  end

  @doc """
  Implementa técnica "RoundRobin paso 1" para conseguir los nodos.

  ## Parámetros

    - agent_name : Átomo que identifica la lista.

  ## Ejemplos
      iex> NodeManager.init(:prueba)
      iex> Agent.update(:prueba, fn list -> [:node1 | list] end)
      iex> Agent.update(:prueba, fn list -> [:node2 | list] end)
      iex> Agent.update(:prueba, fn list -> [:node3 | list] end)
      iex> NodeManager.get(:prueba)
      :node3
      iex> NodeManager.get(:prueba)
      :node2
      iex> NodeManager.get(:prueba)
      :node1
      iex> NodeManager.get(:prueba)
      :node3
      iex> Agent.stop(:prueba)
  """
  @spec get(atom()) :: node()
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
