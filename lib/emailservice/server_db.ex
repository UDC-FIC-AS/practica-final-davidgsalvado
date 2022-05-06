defmodule ServerDb do
  use GenServer

#==========================[SERVER DB FUNCTIONS]===============================#
  def init_db(db_name) do
    GenServer.start_link(ServerDb, Db.new(),
    name: {:global, db_name}, timeout: :infinity)
  end

  def write(db_name, key, element) do
    GenServer.call(db_name, {:write, {key, element}}, :infinity)
  end

  def overwrite(db_name, key, element) do
    GenServer.call(db_name, {:overwrite, {key, element}}, :infinity)
  end

  def read(db_name, key) do
    GenServer.call(db_name, {:read, key}, :infinity)
  end

  def get_all_content(db_name) do
    GenServer.call(db_name, :get_all_content, :infinity)
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

end
