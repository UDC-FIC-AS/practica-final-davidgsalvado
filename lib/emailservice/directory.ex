defmodule Directory do

  @moduledoc """
  Módulo que implementa el directorio.

  Este módulo tiene como finalidad recibir las peticiones de los clientes y
  distribuirlas a los balanceadores de carga.

  """

  @doc """
  Inicializa las listas que alamcenan los nodos de los balanceadores de carga.

  """
  @spec init() :: :ok
  def init do
    NodeManager.init(:user_lbs)
    NodeManager.init(:message_lbs)
  end

  @doc """
  Añade un nodo a la lista correspondiente.

  ## Parámetros

    - lb_type : Átomo que identifica la lista en la que se tiene que agregar el
    nodo del balanceador de carga.
    - lb_node : Nodo a agregar.
  """
  @spec add(atom(), node()) :: {:ok, node()} | {:error, :connection_error}
  def add(lb_type, lb_node) do
    NodeManager.add(lb_type, lb_node)
  end

  @doc """
  Elimina un nodo de la lista correspondiente.

  ## Parámetros

    - lb_type : Átomo que identifica la lista de la que se tiene que eliminar el
    nodo del balanceador de carga.
    - lb_node : Nodo a eliminar.
  """
  @spec remove(atom(), node()) :: :ok
  def remove(lb_type, lb_node) do
    NodeManager.remove(lb_type, lb_node)
  end

  @doc """
  Envía la petición al nodo del balanceador de carga correspondiente.
  En caso de que no pueda realizar la petición se le devuelve al cliente un error.

  ## Parámetros

    - client_rec_pid : Pid al que se tiene que enviar la respuesta.
  """
  @spec receive_request(pid()) :: term()
  def receive_request(client_rec_pid) do
    receive do
      {lb_type, action} ->
        try do
          distribute(client_rec_pid, {lb_type, action})
        catch
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
