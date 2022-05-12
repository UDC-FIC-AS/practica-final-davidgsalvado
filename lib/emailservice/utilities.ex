defmodule Utilities do
  def get_node(node_name, ip) do
    [node_name, "@", ip] |> Enum.join("") |> String.to_atom
  end
end
