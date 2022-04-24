
defmodule DbMessages do
  use GenServer
  @moduledoc """
  Base de datos para xestionar o servizo de mensaxería e os buzóns de mensaxes de cada usuario.
  Garda unha lista composta por pares {usuario,buzón}. O usuario é o nome do propietario do buzón, que é pola súa
  parte é unha lista de pares {mensaxe,lido}. O primeiro é o texto do mensaxe e o segundo é un booleano que indica se
  o mensaxe xa foi lido ou non
  """

  #API con operacións
  defp new(),do: []

  defp write(db,key,element) do
    [{key, element} | db]
  end

  defp delete(db,key),do: delete_key(db,key)

  defp delete_key([{key, _} | tail], key), do: tail
  defp delete_key([pair | tail], key), do: [pair | delete_key(tail, key)]
  defp delete_key([], _ ), do: []

  defp read([],_), do: {:not_found}
  defp read([{k,elem} | _],key) when k == key, do: {:ok,elem}
  defp read([_ | tail],key), do: read(tail,key)

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

  defp delete_lidos_aux([],listaux), do: listaux
  defp delete_lidos_aux([{_, true} | _],listaux), do: listaux
  defp delete_lidos_aux([h | t],listaux), do: delete_lidos_aux( t,[h | listaux])



  #Servidor
  defp start_link do
    GenServer.start_link(__MODULE__,new() , name: :miBD)
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
      {:ok, mess} ->  {newBuzon,_} = ler_mensaxes(mess)
                      deleted = delete(state,usuario)
                      newState = write(deleted,usuario,newBuzon)
                      mensaxes = leer_todos_mensaxes(mess)
                     {:reply,mensaxes,newState}                                                             #aparecerán todos juntos y no habrá que recorrer toda la lista
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

  @doc """
  Inicia a base de datos para comenzar a resolver as peticións
  """
  def init_db() do
    start_link()
  end

  @doc """
  Engade un usuario á base de datos devolve :user_not_valid se xa existe
  na base de datos, sençon devolve :ok
  """
  def add_user(user) do
    GenServer.call(:miBD,{:engadir,user})
  end

  @doc """
  Elimina un usuario da base de datos, se non existe non devolve ningún erro
  """
  def delete_user(user) do
    GenServer.cast(:miBD,{:eliminar,user})
  end

  @doc """
  Envía o mensaxe indicado ó usuario que se lle pasa á función. Este mensaxe se engadirá ó buzón
  do usuario e o marcará como non lido
  """
  def send_message(user, message) do
    GenServer.call(:miBD,{:enviar,user,message})
  end

  @doc """
  Obtén os mensaxes sen leer do buzón do usuario indicado e os marca como lidos no buzón.
  Devolve unha lista coas mensaxes
  """
  def read_messages(user) do
    GenServer.call(:miBD,{:mensaxes_sen_ler,user})
  end

  @doc """
  Borra os mensaxes xa lidos do usuario e deixa no seu buzón só os que están sen ler
  """
  def delete_read_message(user) do
    GenServer.call(:miBD,{:borrar_lidos,user})

  end

  @doc """
  Obtén todas as mensaxes non borradas do buzón do usuario indicado e os marca como lidos no buzón.
  Devolve unha lista coas mensaxes
  """
  def all_messages(user) do
    GenServer.call(:miBD,{:todos_mensaxes,user})
  end

  @doc """
  Resetea a base de datos quitando todos os usuarios xa rexistrados e os seus buzóns
  """
  def reset_db() do
    GenServer.cast(:miBD,{:reset})
  end

  @doc """
  Para a base de datos e mata o proceso
  """
  def stop() do
    GenServer.stop(:miBD)
    :ok
  end
end
