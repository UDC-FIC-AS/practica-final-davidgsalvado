defmodule MXConfig do

  def init_db_users do
    ServerDb.init_db(:user_db)
  end

  def init_db_message do
    ServerDb.init_db(:message_db)
  end

  def init_sv_user do
    UserService.init_user_service
<<<<<<< HEAD
    UserService.add_user_db(:"u_db@***")
    UserService.add_message_db(:"m_db@***")
=======
    UserService.add_user_db(:"u_db@***")
    UserService.add_message_db(:"m_db@***")
>>>>>>> adolfo&sebas_2
  end

  def init_sv_message do
    MessageService.init_message_service
<<<<<<< HEAD
    MessageService.add_db(:"m_db@***")
=======
    MessageService.add_db(:"m_db@***")
>>>>>>> adolfo&sebas_2
  end

  def init_lb_users do
    LoadBalancer.init(:user_lbs)
<<<<<<< HEAD
    LoadBalancer.add_service(:user_lbs, :"s_u1@***")
=======
    LoadBalancer.add_service(:user_lbs, :"s_u1@***")
>>>>>>> adolfo&sebas_2
  end

  def init_lb_message do
    LoadBalancer.init(:message_lbs)
<<<<<<< HEAD
    LoadBalancer.add_service(:message_lbs, :"s_m1@***")
    LoadBalancer.add_service(:message_lbs, :"s_m2@***")
=======
    LoadBalancer.add_service(:message_lbs, :"s_m1@***")
    LoadBalancer.add_service(:message_lbs, :"s_m2@***")
>>>>>>> adolfo&sebas_2
  end

  def init_dir do
    Directory.init()
<<<<<<< HEAD
    Directory.add(:user_lbs, :"lb_u1@***")
    Directory.add(:message_lbs, :"lb_m1@***")
    Directory.add(:message_lbs, :"lb_m2@***")
=======
    Directory.add(:user_lbs, :"lb_u1@***")
    Directory.add(:message_lbs, :"lb_m1@***")
    Directory.add(:message_lbs, :"lb_m2@***")
>>>>>>> adolfo&sebas_2
  end
end
