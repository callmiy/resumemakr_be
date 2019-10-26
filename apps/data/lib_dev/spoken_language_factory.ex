defmodule Data.SpokenLanguageFactory do
  alias Data.Factory

  def params(%{resume_id: _resume_id} = attrs) do
    %{
      description: "description " <> Sequence.next(""),
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
    |> Enum.map(fn {k, v} -> {Factory.to_camel_key(k), v} end)
    |> Enum.into(%{})
  end
end
