defmodule Client do

  @moduledoc """
  Módulo que implementa el cliente.

  Este módulo tiene como finalidad permitir que se ejecuten remotamente
  las funcionalidades que expone el servicio.

  """

  @doc """
  Inicializa la conexión con el directorio.

  ## Parámetros

    - dir_ip : Dirección IP del directorio.
  """
  @spec init(term()) :: {:ok, node()} | {:error, :connection_error}
  def init(dir_ip) do
    dir_node = Utilities.get_node("dir", dir_ip)
    if Node.connect(dir_node) do {:ok, dir_node}
    else {:error, :connection_error} end
  end

  @doc """
  Envía una peteción al directorio para que la reciba la interfaz de usuario o el
  propio cliente.

  ## Parámetros

    - dir_node : Nodo del directorio.
    - request: Tupla con la peteción.
    - respond_to_ui: Indica si se responde a la interfaz gráfica o al cliente.
  """
  @spec send_request(term(), term(), boolean()) :: :ok
  def send_request(dir_node, request, true) do
    rec_pid = spawn(fn -> Ui.receive_response(dir_node) end)
    send_request_aux(dir_node, request, rec_pid)
    :ok
  end

  def send_request(dir_node, request, false) do
    rec_pid = spawn(fn -> receive_response() end)
    send_request_aux(dir_node, request, rec_pid)
    :ok
  end


  @doc """
  Envía una peteción al directorio.

  ## Parámetros

    - dir_node : Nodo del directorio.
    - request: Tupla con la peteción.
    - rec_pid: Pid al que se tiene que enviar la respuesta.
  """
  @spec send_request_aux(term(), term(), pid()) :: :ok
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
