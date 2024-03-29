defmodule MXConfig do

  @moduledoc """
  Este módulo se encarga de inicializar una configuración particular del sistema
  implementado.

  En concreto prepara:
  - Un directorio
  - Un balanceador de carga de usuarios.
  - Dos balanceadores de carga de mensajes.
  - Un servicio de usuarios.
  - Dos servicios de mensajes.
  - La base de datos de usuarios.
  - La base de datos de mensajes.
  """

  @doc """
  inicializa la configuración tomando la como parametro la IP local del ordenador
  en el que se ejecuta.

  """
  @spec init_config(term()) :: term()
  def init_config(ip) do
    node_names = ["dir", "lb_u1", "lb_m1", "lb_m2", "s_u1", "s_m1", "s_m2",
    "u_db", "m_db"]
    node_list = Enum.map(node_names,
    fn node_name ->
      Utilities.get_node(node_name, ip)
    end)
    try do
      Enum.map(
      node_list,
      fn node ->
        ConnectionManager.check_node_connection(node)
      end)
      #init_db_users(u_db)
    catch
      {_, node} -> IO.puts(:stderr, "Error: Connection failed on node #{node}")
    end
    [dir, lb_u1, lb_m1, lb_m2, s_u1, s_m1, s_m2, u_db, m_db] = Node.list

    #Init. example
    init_db_users(u_db)
    init_db_message(m_db)
    init_sv_user(s_u1, u_db, m_db)
    init_sv_message(s_m1, m_db)
    init_sv_message(s_m2, m_db)
    init_lb_users(lb_u1, s_u1)
    init_lb_message(lb_m1, s_m1, s_m2)
    init_lb_message(lb_m2, s_m1, s_m2)
    init_dir(dir, lb_u1, lb_m1, lb_m2)

    :ok
  end


  def init_db_users(u_db_node) do
    Node.spawn(u_db_node, fn -> ServerDb.init_db(:user_db) end)
  end

  def init_db_message(m_db_node)do
    Node.spawn(m_db_node, fn -> ServerDb.init_db(:message_db) end)
  end

  def init_sv_user(s_u_node, u_db_node, m_db_node) do
    Node.spawn(s_u_node,
    fn ->
      UserService.init_user_service
      UserService.add_user_db(u_db_node)
      UserService.add_message_db(m_db_node)
    end)
  end

  def init_sv_message(s_m_node, m_db_node) do
    Node.spawn(s_m_node,
    fn ->
      MessageService.init_message_service
      MessageService.add_db(m_db_node)
    end)
  end

  def init_lb_users(lb_u_node, s_u_node) do
    Node.spawn(lb_u_node,
    fn ->
      LoadBalancer.init(:user_lbs)
      LoadBalancer.add_service(:user_lbs, s_u_node)
    end)
  end

  def init_lb_message(lb_m_node, s_m1_node, s_m2_node) do
    Node.spawn(lb_m_node,
    fn ->
      LoadBalancer.init(:message_lbs)
      LoadBalancer.add_service(:message_lbs, s_m1_node)
      LoadBalancer.add_service(:message_lbs, s_m2_node)
    end)
  end

  def init_dir(dir_node, lb_u1_node, lb_m1_node, lb_m2_node) do
    Node.spawn(dir_node,
    fn ->
      Directory.init()
      Directory.add(:user_lbs, lb_u1_node)
      Directory.add(:message_lbs, lb_m1_node)
      Directory.add(:message_lbs, lb_m2_node)
    end)
  end
end
