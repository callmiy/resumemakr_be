defmodule Data.TextOnlyFactory do
  alias Data.Factory

  def params(%{owner_id: _owner_id, tag: _} = attrs) do
    %{
      text: Sequence.next("text ")
    }
    |> Map.merge(attrs)
  end

  def params(attrs) when is_list(attrs) do
    attrs
    |> Map.new()
    |> params()
  end

  def stringify(attrs) do
    attrs
    |> Enum.map(fn
      {:tag, v} ->
        {"tag", tag(v)}

      {k, v} ->
        {Factory.to_camel_key(k), v}
    end)
    |> Map.new()
  end

  def tag(v) when is_atom(v) do
    v
    |> Atom.to_string()
    |> String.upcase()
  end

  def tag(v) do
    v
  end
end
