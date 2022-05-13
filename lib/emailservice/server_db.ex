defmodule ServerDb do
  use GenServer

  @moduledoc """
  Módulo que implementa un servidor de una base de datos.

  Este módulo tiene como finalidad aportarle conectividad a la base de datos
  para que pueda admitir peticiones de los servicios.

  En este caso soporta peticiones de escritura (write), de sobreescritura
  (overwrite), de lectura (read) y de volcado de contenido (get_all_content).
  Todas las peticiones tienen un timeout de 10 segundos.

  Implementado con GenServer para poder almacenar y modificar el estado de la
  base de datos.
  """

#==========================[SERVER DB FUNCTIONS]===============================#
  @doc """
  Inicializa la base de datos.

  ## Parámetros

    - db_name : Átomo que identifica la base de datos creada.

  ## Ejemplos
      iex> {:ok, pid} = ServerDb.init_db(:prueba)
      iex> Process.alive? pid
      true
      iex> GenServer.stop(pid)
      :ok
  """
  @spec init_db(atom()) :: {:ok, pid()}
  def init_db(db_name) do
    GenServer.start_link(ServerDb, Db.new(),
    name: {:global, db_name}, timeout: 10000)
  end

  @doc """
  Escribe en la base de datos.

  ## Parámetros

    - db_name : Átomo que identifica la base de datos creada.
    - key: Átomo que identifica una clave.
    - element: Elemento cualquiera asociado a la clave.

  ## Ejemplos
      iex> {:ok, pid} = ServerDb.init_db(:prueba)
      iex> ServerDb.write({:global, :prueba}, :key, 1)
      iex> GenServer.call({:global, :prueba}, {:read, :key}, :infinity)
      {:ok, 1}
      iex> GenServer.stop(pid)
  """
  @spec write(atom(), atom(), term()) :: :ok
  def write(db_name, key, element) do
    GenServer.call(db_name, {:write, {key, element}}, 10000)
  end

  @doc """
  Sustituye el elemento con clave "key" por un nuevo elemento.

  ## Parámetros

    - db_name : Átomo que identifica la base de datos creada.
    - key: Átomo que identifica una clave.
    - element: Elemento que sobreescribe el elemento previo.

  ## Ejemplos
      iex> {:ok, pid} = ServerDb.init_db(:prueba)
      iex> GenServer.call({:global, :prueba}, {:write, {:key, 1}}, 10000)
      iex> GenServer.call({:global, :prueba}, {:read, :key}, :infinity)
      {:ok, 1}
      iex> ServerDb.overwrite({:global, :prueba}, :key, 2)
      :ok
      iex> GenServer.call({:global, :prueba}, {:read, :key}, :infinity)
      {:ok, 2}
      iex> GenServer.stop(pid)
  """
  @spec overwrite(atom(), atom(), term()) :: :ok
  def overwrite(db_name, key, element) do
    GenServer.call(db_name, {:overwrite, {key, element}}, 10000)
  end

  @doc """
  Lee el elemento con clave "key".

  ## Parámetros

    - db_name : Átomo que identifica la base de datos creada.
    - key: Átomo que identifica una clave.

  ## Ejemplos
      iex> {:ok, pid} = ServerDb.init_db(:prueba)
      iex> GenServer.call({:global, :prueba}, {:write, {:key, 1}}, 10000)
      iex> ServerDb.read({:global, :prueba}, :key)
      {:ok, 1}
      iex> GenServer.stop(pid)
  """
  @spec read(atom(), atom()) :: {:ok, term()}
  def read(db_name, key) do
    GenServer.call(db_name, {:read, key}, 10000)
  end

  @doc """
  Devuelve la lista que representa a la base de datos.

  ## Parámetros

    - db_name : Átomo que identifica la base de datos creada.

  ## Ejemplos
      iex> {:ok, pid} = ServerDb.init_db(:prueba)
      iex> GenServer.call({:global, :prueba}, {:write, {:key, 1}}, 10000)
      iex> ServerDb.get_all_content({:global, :prueba})
      [key: 1]
      iex> GenServer.stop(pid)
  """
  @spec get_all_content(atom()) :: list()
  def get_all_content(db_name) do
    GenServer.call(db_name, :get_all_content, 10000)
  end

#==========================[SERVER DB CALLBACKS]===============================#
  @impl true
  def init(db_ref) do
    {:ok, db_ref}
  end

  @impl true
  def handle_call({:write, {key, element}}, _from, db_ref) do
    {:reply, :ok, Db.write(db_ref, key, element)}
  end

  @impl true
  def handle_call({:overwrite, {key, element}}, _from, db_ref) do
    {:reply, :ok, Db.overwrite(db_ref, key, element)}
  end

  @impl true
  def handle_call({:read, key}, _from, db_ref) do
    {:reply, Db.read(db_ref, key), db_ref}
  end

  @impl true
  def handle_call(:get_all_content, _from, db_ref) do
    {:reply, db_ref, db_ref}
  end

  @impl true
  def terminate(_, _) do
    :ok
  end

end
