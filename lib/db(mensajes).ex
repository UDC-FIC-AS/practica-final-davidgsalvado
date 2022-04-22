#Bases de datos para la gestión de usuarios de la app de mensajería
#Esta solo lleva los usuarios no los mensajes
#Funcionalidades que incluye la api:
#
# db -> bases de datos que contiene toda la info
# key -> nombre del usuario en la bd
# element -> lista de los mensajes al usuario esta lista se compone de pares:
# {mensaje, leído} -> mensaje contiene el mensaje que recibirá cada usuario, leído es un booleano

defmodule Db do
  use GenServer

  #API con operacións
  defp new(),do: []

  #Escribir un nuevo usuario en la bd
  defp write(db,key,element) do
    [{key, element} | db]
  end

  #borrar un usuario de la bd
  defp delete(db,key),do: delete_key(db,key)

  defp delete_key([{key, _} | tail], key), do: tail
  defp delete_key([pair | tail], key), do: [pair | delete_key(tail, key)]
  defp delete_key([], _ ), do: []

  #revisa que el usuario esté en la bd, si existe devuelve la contraseña del usuario
  #si no existe devuelve not found y se puede registrar el nombre
  defp read([],_), do: {:not_found}
  defp read([{k,elem} | _],key) when k == key, do: {:ok,elem}
  defp read([_ | tail],key), do: read(tail,key)

  #reiniciar BD
  defp destroy(_),do: []

  defp move_head(list) do
    [head | tail] = list
    list = tail ++ [head]
    list
  end

  defp ler_mensaxes(mess), do: ler_mensaxes_aux(mess,[])

  defp ler_mensaxes_aux([],list_aux), do: {[],list_aux}
  defp ler_mensaxes_aux([{mess,true} | t],list_aux), do:  {[{mess,true} | t], list_aux}
  defp ler_mensaxes_aux( [{mess,false} | t] ,list_aux), do: ler_mensaxes_aux(t ++ [{mess,true}],list_aux ++ [mess])



  defp leer_todos_mensaxes(buzon), do: leer_todos_mensaxes_aux(buzon, [])
  defp leer_todos_mensaxes_aux([], aux), do: aux
  defp leer_todos_mensaxes_aux([{mess,_} | t], aux), do: leer_todos_mensaxes_aux(t, [mess | aux])


  defp delete_lidos(lista), do: delete_lidos_aux(lista,[])

  #En esta función da igual darle la vuelta a la lista, total siguen estando todos los resultantes sin leer
  defp delete_lidos_aux([],listaux), do: listaux
  defp delete_lidos_aux([{_, true} | _],listaux), do: listaux
  defp delete_lidos_aux([h | t],listaux), do: delete_lidos_aux( t,[h | listaux])



  #Servidor
  defp start_link do
    GenServer.start_link(__MODULE__,new() , name: :miBD) # start server
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_call({:buscar,usuario},_from,state) do
    list = read(state,usuario)
    case list do
      {:not_found} -> {:reply,:user_not_register,state}

      {:ok,elem} -> {:reply,elem,state}
    end
  end

  @impl true
  def handle_call({:enviar, usuario, mensaxe},_from,state) do
    buzon = read(state,usuario)
    case buzon do
      {:not_found} -> {:reply,:error_user_does_not_exist,state}
      {:ok, mess} -> deleted = delete(state,usuario)
                     newState = write(deleted,usuario,[{mensaxe, false} | mess])   #mete los mensajes nuevos en la cabeza, cuando los busque
                     {:reply,:ok,newState}                                                             #aparecerán todos juntos y no habrá que recorrer toda la lista
    end

  end

  @impl true
  def handle_call({:mensaxes_sen_ler, usuario}, _from, state) do
    buzon = read(state,usuario)
    case buzon do
       {:not_found} -> {:reply,:error_user_does_not_exist,state}

       {:ok, mess} -> {newBuzon,mensaxes} = ler_mensaxes(mess)
                      deleted = delete(state,usuario)
                      newState = write(deleted,usuario,newBuzon)
                      {:reply, mensaxes, newState}

    end
  end

  @impl true
  def handle_call({:borrar_lidos, usuario},_from,state) do
    buzon = read(state,usuario)
    case buzon do
      {:not_found} -> {:reply,:error_user_does_not_exist,state}
      {:ok, mess} -> nonlidos = delete_lidos(mess)
                     deleted = delete(state,usuario)
                     newState = write(deleted,usuario,nonlidos)   #mete los mensajes nuevos en la cabeza, cuando los busque
                     {:reply,:ok,newState}                                                             #aparecerán todos juntos y no habrá que recorrer toda la lista
    end

  end

  @impl true
  def handle_call({:todos_mensaxes, usuario},_from,state) do
    buzon = read(state,usuario)
    case buzon do
      {:not_found} -> {:reply,:error_user_does_not_exist,state}
      {:ok, mess} -> mensaxes = leer_todos_mensaxes(mess)
                     {:reply,mensaxes,state}                                                             #aparecerán todos juntos y no habrá que recorrer toda la lista
    end

  end

  @impl true
  def handle_call({:engadir,usuario},_from,state) do
    list = read(state,usuario)
    case list do
      {:ok,_} -> {:reply,:user_not_valid,state}

      {:not_found} -> newState = write(state,usuario,[])
                      newState = move_head(newState)
                    {:reply,:ok,newState}
    end
  end

  @impl true
  def handle_cast({:eliminar,usuario},state) do
    newState = delete_key(state,usuario)
    {:noreply,newState}
  end

  @impl true
  def handle_cast({:reset},state) do
    newState = destroy(state)
    {:noreply,newState}
  end

  #Cliente
  def iniciar_db() do
    start_link()
  end

  def engadir_usuario(usuario) do
    GenServer.call(:miBD,{:engadir,usuario})
  end

  def quitar_usuario(usuario) do
    GenServer.cast(:miBD,{:eliminar,usuario})
  end

  def enviar_mensaxe(usuario, mensaxe) do     ##aquí o usuario é o destinatario do mensaxe
    GenServer.call(:miBD,{:enviar,usuario,mensaxe})
  end

  def obter_mensaxes_sen_leer(usuario) do
    GenServer.call(:miBD,{:mensaxes_sen_ler,usuario})
  end

  def borrar_mensaxes_lidos(usuario) do
    GenServer.call(:miBD,{:borrar_lidos,usuario})

  end

  def devolver_todos_os_mensaxes(usuario) do
    GenServer.call(:miBD,{:todos_mensaxes,usuario})
  end

  def reset_db() do
    GenServer.cast(:miBD,{:reset})
  end

  def disolver() do
    GenServer.stop(:miBD)
    :ok
  end
end
