defmodule MXConfig do
  def init_lb_users() do
    LoadBalancer.init(:user_lbs)
    LoadBalancer.add_service(:user_lbs, :"s_u1@192.168.1.134")
  end

  def init_lb_message() do
    LoadBalancer.init(:message_lbs)
    LoadBalancer.add_service(:message_lbs, :"s_m1@192.168.1.134")
  end

  def init_dir() do
    Directory.init()
    Directory.add(:user_lbs, :"lb_u1@192.168.1.134")
    Directory.add(:message_lbs, :"lb_m1@192.168.1.134")
  end
end
