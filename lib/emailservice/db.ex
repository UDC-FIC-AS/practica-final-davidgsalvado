defmodule Db do

  @moduledoc """
  Módulo que se encarga de implementar las funcionalidades de las BDs.

  """

  @doc """
  Devuelve una BD vacia.

  """
  @spec new() :: list()
  def new do
    []
  end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Inserta una tupla ({key, element}) al principio de la BD.

  """
  @spec write(list(), term(), term()) :: list()
  def write(db_ref, key, element), do: [{key, element} | db_ref]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Elimina una tupla referenciada por key de la BD.

  """
  @spec delete(list(), term()) :: list()
  def delete(db_ref, key), do: aux_delete(db_ref, key, [], false)

  defp aux_delete([], _, new_db_ref, _), do: new_db_ref

  defp aux_delete([{k, v} | t], key, new_db_ref, true) do
    aux_delete(t, key, [{k, v} | new_db_ref], true)
  end

  defp aux_delete([{k, _} | t], key, new_db_ref, false) when key == k do
    aux_delete(t, key, new_db_ref, true)
  end

  defp aux_delete([{k, v} | t], key, new_db_ref, false) do
    aux_delete(t, key, [{k, v} | new_db_ref], false)
  end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Sobrescribe una tupla en la BD

  """
  @spec overwrite(list(), term(), term()) :: list()
  def overwrite(db_ref, key, element) do
    new_db_ref = delete(db_ref, key)
    write(new_db_ref, key, element)
  end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @doc """
  Devuelve el elemento referenciado por key. En caso de no encontrarlo devuelve
  un error.

  """
  @spec read(list(), term()) :: list() | {:error, :not_found}
  def read([], _), do: {:error, :not_found}

  def read([{k, v} | _], key) when k == key, do: {:ok, v}

  def read([{_, _} | t], key), do: read(t, key)


end
