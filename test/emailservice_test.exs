defmodule EmailserviceTest do
  use ExUnit.Case

  defp receive_response(expected_resp) do
    receive do
      {:ok, resp} ->
        assert expected_resp == resp
        send(self(), :stop)
      {:error, error} ->
        assert expected_resp == error
        send(self(), :stop)
      :stop -> :ok
    end
  end

  setup do
    nodes = [:"dir@192.168.80.2", :"client@192.168.80.2", :"lb_u1@192.168.80.2", :"lb_m1@192.168.80.2", :"s_u1@192.168.80.2",
    :"s_m1@192.168.80.2", :"u_db@192.168.80.2", :"m_db@192.168.80.2"]

    Enum.map(nodes, fn node -> Node.connect(node) end) # nos conectamos a los nodos

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
    Client.init(:"dir@192.168.80.2")
    Client.send_request_aux(:"dir@192.168.80.2", {:user_lbs, {:register, {"David", "password"}}}, self())
    receive_response({:register, :registered_succesfully})

    Client.send_request_aux(:"dir@192.168.80.2", {:user_lbs, {:register, {"David", "password"}}}, self())
    receive_response({:error, :user_already_registered})
  end
end
