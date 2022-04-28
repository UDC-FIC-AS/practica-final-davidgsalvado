defmodule ServiceUsers do
  def init_service(user_db_ip) do
    db_node = ["user_db@", user_db_ip] |> Enum.join("") |> String.to_atom

    if Node.connect(db_node) do {:ok, db_node}
    else {:error, :connection_error} end
  end

  def register(username, password), do: IO.puts username
end
