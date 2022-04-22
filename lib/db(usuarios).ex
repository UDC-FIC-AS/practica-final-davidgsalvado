#Bases de datos para la gestión de usuarios de la app de mensajería
#Esta solo lleva los usuarios no los mensajes
#Funcionalidades que incluye la api:
#
# db -> bases de datos que contiene toda la info
# key -> nombre del usuario en la bd
# element -> contraseña asociada a un usuario
defmodule Db do
  use GenServer

  #API con operacións
  def new(),do: []

  #Escribir un nuevo usuario en la bd
  def write(db,key,element) do
    [{key, element} | db]
  end

  #borrar un usuario de la bd
  def delete(db,key),do: delete_key(db,key)

  defp delete_key([{key, _} | tail], key), do: tail
  defp delete_key([pair | tail], key), do: [pair | delete_key(tail, key)]
  defp delete_key([], _ ), do: []

  #revisa que el usuario esté en la bd, si existe devuelve la contraseña del usuario
  #si no existe devuelve not found y se puede registrar el nombre
  def read([],_), do: {:not_found}
  def read([{k,elem} | _],key) when k == key, do: {:ok,elem}
  def read([_ | tail],key), do: read(tail,key)

  #obtener todos los uduarios
  def list_users([],list), do: list
  def list_users([{k,_} | t],list), do: list_users(t,[k] ++ list)

  #reiniciar BD
  def destroy(_),do: []


  #Servidor
  defp move_head(list) do
    [head | tail] = list
    list = tail ++ [head]
    list
  end

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
      {:not_found} -> {:reply,:user_not_found,state}

      {:ok,_} -> {:reply,:ok,state}
    end
  end

  @impl true
  def handle_call({:contrasinal,usuario},_from,state) do
    list = read(state,usuario)
    case list do
      {:not_found} -> {:reply,:user_not_register,state}

      {:ok,elem} -> {:reply,elem,state}
    end
  end

  @impl true
  def handle_call({:listar},_from,state) do
    lista = list_users(state,[])
    {:reply,lista,state}
  end

  @impl true
  def handle_call({:engadir,usuario, contrasinal},_from,state) do
    list = read(state,usuario)
    case list do
      {:ok,_} -> {:reply,:user_not_valid,state}

      {:not_found} -> newState = write(state,usuario,contrasinal)
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

  def revisar_usuario(usuario) do
    GenServer.call(:miBD,{:buscar,usuario})
  end

  def revisar_contrasinal_de_usuario(usuario) do
    GenServer.call(:miBD,{:contrasinal,usuario})
  end

  def engadir_usuario(usuario,contrasinal) do
    GenServer.call(:miBD,{:engadir,usuario,contrasinal})
  end

  def quitar_usuario(usuario) do
    GenServer.cast(:miBD,{:eliminar,usuario})
  end

  def obter_usuarios() do
    GenServer.call(:miBD,{:listar})
  end

  def reset_db() do
    GenServer.cast(:miBD,{:reset})
  end

  def disolver() do
    GenServer.stop(:miBD)
    :ok
  end
end
