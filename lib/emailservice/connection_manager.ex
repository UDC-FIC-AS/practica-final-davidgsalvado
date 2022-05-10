defmodule ConnectionManager do
  def check_db_connection(db_name) do
    db_node = NodeManager.get(db_name)
    has_connection = Node.connect(db_node)
    case has_connection do
      true -> :ok
      false -> raise "db_connection_error"
    end
  end

  def check_node_connection(node) do
    has_connection = Node.connect(node)
    case has_connection do
      true -> :ok
      false -> raise "node_connection_error"
    end
  end
end
