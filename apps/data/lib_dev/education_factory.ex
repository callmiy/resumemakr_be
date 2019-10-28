defmodule Data.EducationFactory do
  alias Data.Factory
  alias Data.Resumes

  def insert(attrs) do
    attrs = params(attrs)

    {:ok, education} = Resumes.create_education(attrs)
    education
  end

  def params(%{resume_id: _} = attrs) do
    seq = Sequence.next("")

    %{
      index: 1,
      course: "Course " <> seq,
      from_date: "03/2000",
      school: "School " <> seq,
      to_date: "04/2004"
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
      {k, v} ->
        {Factory.to_camel_key(k), stringify(v)}
    end)
    |> Map.new()
  end
end
