defmodule LoadBalancer do

  @moduledoc """
  Módulo que implementa un balanceador de carga.

  Este módulo tiene como finalidad recibir las peticiones que le asigne el
  directorio y redirigirlas al nodo de un servicio para su resolución.
  """

  @doc """
  Inicializa la lista que alamcena los nodos de un tipo servicio determinado.

  - sv_type : Átomo que identifica el tipo de servicio al que pertenecen los nodos
  de la lista.
  """
  @spec init(atom()) :: :ok
  def init(sv_type) do
    NodeManager.init(sv_type)
  end

  @doc """
  Añade el nodo de un servicio a la lista.

  - sv_type : Átomo que identifica el tipo de servicio al que pertenecen los nodos
  de la lista.
  - sv_node : Átomo que identifica el nodo a agregar.
  """
  @spec add_service(atom(), node()) :: {:ok, node()} | {:error, :connection_error}
  def add_service(sv_type, sv_node) do
    NodeManager.add(sv_type, sv_node)
  end

  @doc """
  Elimina el nodo de la  lista.

  - sv_type : Átomo que identifica el tipo de servicio al que pertenecen los nodos
  de la lista.
  - sv_node : Átomo que identifica el nodo a eliminar.
  """
  @spec remove_service(atom(), node()) :: :ok
  def remove_service(sv_type, sv_node) do
    NodeManager.remove(sv_type, sv_node)
  end

  @doc """
  Envía la petición al nodo del servico correspondiente.
  En caso de que no pueda realizar la petición se le devuelve al directorio un error.

  - dir_rec_pid : Pid al que se tiene que enviar la respuesta.
  """
  @spec receive_request(pid()) :: term()
  def receive_request(dir_rec_pid) do
    receive do
      {lb_type, {action, args}} ->
        try do
          process_action(lb_type, {action, args}, dir_rec_pid)
        catch
          _ -> send(dir_rec_pid, {:error, :service_connection_error})
        end
      end
  end

  defp process_action(sv_type, {action, args}, dir_rec_pid) do
    sv_node = NodeManager.get(sv_type)
    ConnectionManager.check_node_connection(sv_node)
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
