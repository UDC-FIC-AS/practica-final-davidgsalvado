defmodule Db do
  def new do
    []
  end

  #write
  def write(db_ref, key, element), do: [{key, element} | db_ref]

  #delete
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

  #read
  def read([], _), do: {:error, :not_found}

  def read([{k, v} | _], key) when k == key, do: {:ok, v}

  def read([{_, _} | t], key), do: read(t, key)

  #match
  def match(db_ref, element), do: aux_match([], db_ref, element)

  defp aux_match(l_keys, [], _), do: l_keys

  defp aux_match(l_keys, [{k, v} | t], element) when v == element do
    aux_match([k | l_keys], t, element)
  end

  defp aux_match(l_keys, [{_, _} | t], element) do
    aux_match(l_keys, t, element)
  end

  def destroy(_) do
    :ok
  end  

end
