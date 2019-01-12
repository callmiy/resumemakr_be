defmodule Data.Factory do
  @start_date ~D[1998-01-01]
  @end_date ~D[2018-12-31]
  @now Timex.now()
  @all_seconds_in_year 0..(360 * 24 * 60 * 60)

  def map(built), do: Map.from_struct(built)

  def random_date, do: Faker.Date.between(@start_date, @end_date)

  def random_datetime,
    do:
      @now
      |> Timex.beginning_of_year()
      |> Timex.add(Timex.Duration.from_seconds(Enum.random(@all_seconds_in_year)))

  def to_camel_key(key) when is_binary(key) do
    [first | rest] = String.split(key, "_")
    first <> Enum.reduce(rest, "", &(&2 <> String.capitalize(&1)))
  end

  def to_camel_key(key) when is_atom(key) do
    key
    |> Atom.to_string()
    |> to_camel_key()
  end

  def random_string_int, do: Integer.to_string(Faker.random_between(2, 100))

  def reject_attrs(%{} = attrs) do
    Enum.reduce(attrs, %{}, fn
      {_k, nil}, acc ->
        acc

      {_, %Ecto.Association.NotLoaded{}}, acc ->
        acc

      {:__meta__, _}, acc ->
        acc

      {k, %Plug.Upload{} = v}, acc ->
        Map.put(acc, k, v)

      {k, "nil"}, acc ->
        Map.put(acc, k, nil)

      {k, val}, acc ->
        Map.put(acc, k, reject_attrs(val))
    end)
  end

  def reject_attrs(attrs) when is_list(attrs) do
    Enum.map(attrs, &reject_attrs(&1))
  end

  def reject_attrs(v), do: v

  defmacro __using__(_opts) do
    quote do
      def params(attrs \\ %{})

      def params(attrs) when is_list(attrs),
        do:
          attrs
          |> Map.new()
          |> params

      def insert_list(how_many, attrs \\ %{})

      def insert_list(how_many, attrs) when is_list(attrs),
        do: insert_list(how_many, Map.new(attrs))

      def insert_list(how_many, attrs),
        do:
          1..how_many
          |> Enum.map(fn _ -> insert(attrs) end)

      def insert(attrs \\ %{})

      def insert(attrs) when is_list(attrs),
        do:
          attrs
          |> Map.new()
          |> insert
    end
  end
end
