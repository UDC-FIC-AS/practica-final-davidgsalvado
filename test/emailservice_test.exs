defmodule EmailserviceTest do
  use ExUnit.Case

  setup do
    # IMPORTANTE: LOS NODOS SE TIENEN QUE ARRANCAR A MANO PARA QUE EL TEST LOS PUEDA CONFIGURAR.
    ip = "192.168.1.135"
    MXConfig.init_config(ip) # SUSTITUIR IP PARA CONFIGURAR LOS NODOS

    Client.init(ip)

    Process.sleep(10_000) # damos tiempo a los nodos para configurarse

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
    nodes = Node.list()

    #***************************************** SERVICIO DE USUARIOS ***************************************************************
    # - REGISTRO DE USUARIOS
    Client.send_request_aux(List.first(nodes), {:user_lbs, {:register, {"David", "password"}}}, self()) # registro con usuario no existente
    assert_receive {:ok, {:register, :registered_succesfully}}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:register, {"Adrian", "password"}}}, self()) # registro con usuario no existente
    assert_receive {:ok, {:register, :registered_succesfully}}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:register, {"David", "password"}}}, self()) # registro de usuario ya registrado
    assert_receive {:error, :user_already_registered}, 10000

    # - LOGIN DE USUARIOS
    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login, {"David", "password"}}}, self()) # login de usuario registrado
    assert_receive {:ok, {:login, :correct_password}}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login,  {"David", "incorrect_password"}}}, self()) # login de contraseña incorrecta
    assert_receive {:error, :wrong_password}, 10000

    Client.send_request_aux(List.first(nodes), {:user_lbs, {:login,  {"Mar", "password"}}}, self()) # login con usuario no registrado
    assert_receive {:error, :user_does_not_exist}, 10000

    # - LISTAR USUARIOS REGISTRADOS
    Client.send_request_aux(List.first(nodes), {:user_lbs, {:list_users, ""}}, self())
    assert_receive {:ok, {:list_users, ["David", "Adrian"]}}, 10000

    #***************************************** SERVICIO DE MENSAJES ***************************************************************
    # - ENVIAR MENSAJES
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:send_message, {{"Adrian","David"}, "Hola"}}}, self()) # mensaje nuevo
    assert_receive {:ok, {:send_message, :messsage_sent_succesfully}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:send_message, {{"David","Mar"}, "Hola"}}}, self()) # mensaje a usuario no existente
    assert_receive {:error, {:send_message, :user_does_not_exist}}, 10000

    # - LEER MENSAJES NO LEÍDOS (los lee y los marca como leídos)
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_unseen, "David"}}, self()) # usuario registrado con mensajes
    assert_receive {:ok, {:read_unseen, [{"Adrian", "Hola"}]}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_unseen, "Adrian"}}, self()) # usuario registrado sin mensajes
    assert_receive {:ok, {:read_unseen, []}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_unseen, "Mar"}}, self()) # usuario no registrado
    assert_receive {:error, {:read_unseen, :user_does_not_exist}}, 10000

    # - EJEMPLO DE FUNCIONALIDAD (Parte 1: se añade otro mensaje para tener un mensaje leido y otro no leidos en el buzón)
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:send_message, {{"Adrian","David"}, "Buenas tardes!"}}}, self())
    assert_receive {:ok, {:send_message, :messsage_sent_succesfully}}, 10000

    # - LEER TODOS LOS MENSAJES (leidos y NO leidos y los marca como leidos si no lo están)
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_all, "David"}}, self()) # usuario registrado
    assert_receive {:ok, {:read_all, [{"Adrian", "Hola"}, {"Adrian", "Buenas tardes!"}]}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_all, "Mar"}}, self()) # usuario no registrado
    assert_receive {:error, {:read_all, :user_does_not_exist}}, 10000

    # - BORRAR MENSAJES LEIDOS
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:delete_seen, "Mar"}}, self()) # usuario no registrado
    assert_receive {:error, {:delete_seen, :user_does_not_exist}}, 10000


    # - EJEMPLO DE FUNCIONALIDAD (Parte 2: se leen los no leidos y leidos antes y después de borrar los leidos)
    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_unseen, "David"}}, self())
    assert_receive {:ok, {:read_unseen, []}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_all, "David"}}, self())
    assert_receive {:ok, {:read_all, [{"Adrian", "Hola"}, {"Adrian", "Buenas tardes!"}]}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:delete_seen, "David"}}, self())
    assert_receive {:ok, {:delete_seen, :deleted_succesfully}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_unseen, "David"}}, self())
    assert_receive {:ok, {:read_unseen, []}}, 10000

    Client.send_request_aux(List.first(nodes), {:message_lbs, {:read_all, "David"}}, self())
    assert_receive {:ok, {:read_all, []}}, 10000
  end
end
