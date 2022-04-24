
defmodule DbUsers do
  use GenServer
  @moduledoc """
  Base de datos para rexistar pares de tipo {usuario, contrasinal} onde o primerio gardaría o nome dun usuario
  dado de alta na base de datos e o contrasinal indica o valor do contrasinal que ese usuario indicou ó
  rexistrarse
  """

  #API con operacións

  defp new(),do: []

  defp write(db,key,element) do
    [{key, element} | db]
  end

  defp delete_key([{key, _} | tail], key), do: tail
  defp delete_key([pair | tail], key), do: [pair | delete_key(tail, key)]
  defp delete_key([], _ ), do: []

  defp read([],_), do: {:not_found}
  defp read([{k,elem} | _],key) when k == key, do: {:ok,elem}
  defp read([_ | tail],key), do: read(tail,key)

  defp list_users([],list), do: list
  defp list_users([{k,_} | t],list), do: list_users(t,[k] ++ list)

  defp destroy(_),do: []


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

  @spec init_db() :: {:ok, pid}
  @doc """
  Inicia a base de datos para comenzar a resolver as peticións
  """
  def init_db() do
    start_link()
  end

  @spec check_user_exists(String.t()) :: :ok | :user_not_valid
  @doc """
  Revisa se na base de datos existe o usuario indicado como parámetro
  Devolve :ok se non existe e :user_not_valid se xa existe na base de datos

  ## Parámetros

    - user : String que identifica ó usuario

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.add_user("pepito", "passw")
      iex> DbUsers.check_user_exists("pepito")
      :ok
      iex> DbUsers.stop()
      :ok
  """
  def check_user_exists(user) do
    GenServer.call(:miBD,{:buscar,user})
  end

  @spec get_password(String.t()) :: String.t()
  @doc """
  Obtén o contrasinal dun usuario dentro da base de datos.
  Se non existe devolve :user_not_register

  ## Parámetros

    - user : String que identifica ó usuario

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.get_password("pepito")
      :user_not_register
      iex> DbUsers.stop()
      :ok
  """
  def get_password(user) do
    GenServer.call(:miBD,{:contrasinal,user})
  end

  @spec add_user(String.t(), String.t()) :: :ok | :user_not_valid
  @doc """
  Engade un usuario á base de datos xunto coa contrasinal que terá asociada.
  Devolve :user_not_valid se xa existe na base de datos, senón devolve :ok

  ## Parámetros

    - user : Usuario a añadir
    - passw : Contraseña asociada

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.add_user("pepito", "password")
      :ok
      iex> DbUsers.stop()
      :ok
  """
  def add_user(user,passw) do
    GenServer.call(:miBD,{:engadir,user,passw})
  end

  @spec delete_user(String.t()) :: :ok
  @doc """
  Elimina un usuario da base de datos. Se non existe non devolve ningún erro

  ## Parámetros

    - user : Usuario que se quere eliminar

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.add_user("pepito", "password")
      iex> DbUsers.delete_user("pepito")
      :ok
      iex> DbUsers.stop()
      :ok
  """
  def delete_user(user) do
    GenServer.cast(:miBD,{:eliminar,user})
  end

  @spec get_users() :: term()
  @doc """
  Obtén a lista de usuarios rexistrados na base de datos devolvendo unha lista cos nomes.
  Se non hai usuarios rexistrados, devolve lista vacía, en ningún caso devolve erro

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.add_user("pepito", "password")
      iex> DbUsers.add_user("pepe", "passw")
      iex> DbUsers.get_users()
      ["pepe", "pepito"]
      iex> DbUsers.stop()
      :ok
  """
  def get_users() do
    GenServer.call(:miBD,{:listar})
  end

  @spec reset_db() :: :ok
  @doc """
  Resetea a base de datos quitando todos os usuarios xa rexistrados

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.add_user("pepito", "passw")
      iex> DbUsers.reset_db()
      :ok
      iex> DbUsers.get_users()
      []
      iex> DbUsers.stop()
      :ok
  """
  def reset_db() do
    GenServer.cast(:miBD,{:reset})
  end

  @spec stop() :: :ok
  @doc """
  Para a base de datos e mata o proceso

  ## Exemplos
      iex> DbUsers.init_db()
      iex> DbUsers.stop()
      :ok
  """
  def stop() do
    GenServer.stop(:miBD)
    :ok
  end
end
