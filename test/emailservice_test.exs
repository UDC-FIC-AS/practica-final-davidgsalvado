defmodule EmailserviceTest do
  use ExUnit.Case

  setup do

    Node.spawn(:"u_db1@192.168.80.2", fn -> MXConfig.init_db_users() end)
    Node.spawn(:"m_db1@192.168.80.2", fn -> MXConfig.init_db_message() end)
    Node.spawn(:"s_u1@192.168.80.2", fn -> MXConfig.init_sv_user() end)
    Node.spawn(:"s_m1@192.168.80.2", fn -> MXConfig.init_sv_message() end)
    Node.spawn(:"lb_u1@192.168.80.2", fn -> MXConfig.init_lb_users() end)
    Node.spawn(:"lb_m1@192.168.80.2", fn -> MXConfig.init_lb_message() end)
    Node.spawn(:"dir@192.168.80.2", fn -> MXConfig.init_dir() end)
    Node.spawn(:"client@192.168.80.2", fn -> Client.init(:"dir@192.160.80.2") end)
    :ok
  end

  test "integration of all the system" do
    Client.send_request(:"dir@192.168.80.2", {:user_lbs, {:register, {"David", "password"}}}, false)
    assert Client.receive_response() == {:register, :registered_succesfully}
  end
end
