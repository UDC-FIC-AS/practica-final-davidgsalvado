defmodule UserService do

  @moduledoc """
  Módulo que implementa el servicio de usuario.

  Este módulo tiene como finalidad recibir las peticiones asignadas por los
  balanceadores de carga, resolverlas y devolver la respuesta al directorio.

  Atiende los siguientes tipos de peticiones:
    - register
    - login
    - list_users
  """

  @doc """
  Inicializa los NodeManager en los que se guardan los nodo que referencian a las
  bases de datos de mensajes y usuarios.

  """
  @spec init_user_service() :: :ok
  def init_user_service do
    NodeManager.init(:user_db)
    NodeManager.init(:message_db)
  end

  @doc """
  Añade un nodo de base de datos de usuarios. Únicamnete se debe agregar un nodo.

  ## Parámetros
    - db_node : Nodo a agregar.
  """
  @spec add_user_db(node()) :: {:ok, node()} | {:error, :connection_error}
  def add_user_db(db_node) do
    NodeManager.add(:user_db, db_node)
  end

  @doc """
  Añade un nodo de base de datos de mensajes. Únicamnete se debe agregar un nodo.

  ## Parámetros
    - db_node : Nodo a agregar.
  """
  @spec add_message_db(node()) :: {:ok, node()} | {:error, :connection_error}
  def add_message_db(db_node) do
    NodeManager.add(:message_db, db_node)
  end

  @doc """
  Recibe una petición del balanceador de carga, la resuleve y envia la respuesta
  al directorio.

  ## Parámetros
    - dir_rec_pid : Pid al que se tiene que enviar la respuesta.
  """
  @spec receive_request(pid()) :: term()
  def receive_request(dir_rec_pid) do
    receive do
      {action, args} ->
        try do
          execute_action({action, args}, dir_rec_pid)
        catch
          _ -> send(dir_rec_pid, {:error, :db_connection_error})
        end
    end
  end

  defp execute_action({:register, {username, password}}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.read({:global, :user_db}, username)

    case resp do
      {:error, :not_found} ->
        ConnectionManager.check_db_connection(:user_db)
        ServerDb.write({:global, :user_db}, username, password)
        ConnectionManager.check_db_connection(:message_db)
        ServerDb.write({:global, :message_db}, username, [])
        send(dir_rec_pid, {:ok, {:register, :registered_succesfully}})

      _ -> send(dir_rec_pid, {:error, :user_already_registered})
    end
  end

  defp execute_action({:login, {username, password}}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.read({:global, :user_db}, username)

    case resp do
      {:error, :not_found} ->
        send(dir_rec_pid, {:error, :user_does_not_exist})
      {:ok, pass} ->
        if password == pass do
          send(dir_rec_pid, {:ok, {:login, :correct_password}})
        else
          send(dir_rec_pid, {:error, :wrong_password})
        end
    end
  end

  defp execute_action({:list_users, _}, dir_rec_pid) do
    ConnectionManager.check_db_connection(:user_db)
    resp = ServerDb.get_all_content({:global, :user_db})
    name_list = filter_names(resp, [])
    send(dir_rec_pid, {:ok, {:list_users, name_list}})
  end

  defp filter_names([], name_list), do: name_list
  defp filter_names([{username, _} | t], name_list) do
    filter_names(t, [username | name_list])
  end

end
