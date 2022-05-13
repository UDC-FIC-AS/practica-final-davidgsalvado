defmodule ConnectionManager do
  def check_db_connection(db_name) do
    db_node = NodeManager.get(db_name)
    has_connection = Node.connect(db_node)
    case has_connection do
      true -> :ok
      false -> throw {"db_connection_error", db_node}
    end
  end

  def check_node_connection(node) do
    has_connection = Node.connect(node)
    case has_connection do
      true -> :ok
      false -> throw {"node_connection_error", node}
    end
  end
end
