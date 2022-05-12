defmodule EmailserviceTest do
  use ExUnit.Case

  defp get_node(node_name, ip) do
    [node_name, "@", ip] |> Enum.join("") |> String.to_atom
  end

  defp get_nodes() do
    ip = "192.168.80.2" # sustituir por tu IP (IMPORTANTE)

    node_names = ["dir", "lb_u1", "lb_m1", "s_u1",
    "s_m1", "u_db", "m_db"]

    Enum.map(node_names, fn node_name -> get_node(node_name, ip) end)
  end

  setup do

    nodes = get_nodes()

    Enum.map(nodes, fn node -> Node.connect(node) end) # nos conectamos a los nodos

    Client.init(List.first(nodes))

    # Node.spawn(:"u_db@192.168.80.2", fn -> MXConfig.init_db_users() end)
    # Node.spawn(:"m_db@192.168.80.2", fn -> MXConfig.init_db_message() end)
    # Node.spawn(:"s_u1@192.168.80.2", fn -> MXConfig.init_sv_user() end)
    # Node.spawn(:"s_m1@192.168.80.2", fn -> MXConfig.init_sv_message() end)
    # Node.spawn(:"lb_u1@192.168.80.2", fn -> MXConfig.init_lb_users() end)
    # Node.spawn(:"lb_m1@192.168.80.2", fn -> MXConfig.init_lb_message() end)
    # Node.spawn(:"dir@192.168.80.2", fn -> MXConfig.init_dir() end)
    # Node.spawn(:"client@192.168.80.2", fn -> Client.init(:"dir@192.160.80.2") end)
    :ok
  end

  test "integration of all the system" do
    nodes = get_nodes()

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:register, {"David", "password"}}}, self()) # registro con usuario no existente
    assert_receive {:ok, {:register, :registered_succesfully}}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:register, {"David", "password"}}}, self()) # registro de usuario ya registrado
    assert_receive {:error, :user_already_registered}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login,  {"David", "password"}}}, self()) # login de usuario registrado
    assert_receive {:ok, {:login, :correct_password}}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login,  {"David", "incorrect_password"}}}, self()) # login de contraseña incorrecta
    assert_receive {:error, :wrong_password}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login,  {"Adrián", "password"}}}, self()) # login con usuario no registrado
    assert_receive {:error, :user_does_not_exist}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:list_users, ""}}, self())
    assert_receive {:list_users, ["David"]}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:send, {"David", ?}}}, self())
    assert_receive {:send_message, :message_sent_succesfully}, 10000

  end
end
