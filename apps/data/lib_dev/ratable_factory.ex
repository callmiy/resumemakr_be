defmodule Data.RatableFactory do
  alias Data.Factory

  def params(
        %{
          resume_id: _resume_id,
          ratable_type: _
        } = attrs
      ) do
    %{
      description: Sequence.next("description "),
      level: Sequence.next("level ")
    }
    |> Map.merge(attrs)
  end

  def params(attrs) when is_list(attrs) do
    attrs
    |> Map.new()
    |> params()
  end

  def stringify(params) do
    params
    |> Enum.map(fn
      {:ratable_type, v} ->
        {"ratableType", ratable_type(v)}

      {k, v} ->
        {Factory.to_camel_key(k), v}
    end)
    |> Enum.into(%{})
  end

  def ratable_type(type) when is_atom(type) do
    type
    |> Atom.to_string()
    |> String.upcase()
  end

  def ratable_type(type) do
    type
  end
end
