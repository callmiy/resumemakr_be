defmodule Data.FactoryResume do
  use Data.Factory

  alias Data.Factory
  alias Data.Resumes

  @one_nil [1, nil]
  # @simple_attrs [:user_id, :title, :description]

  @doc false
  def insert(attrs) do
    attrs = params(attrs)
    {:ok, resume} = Resumes.create_resume(attrs)
    resume
  end

  def params(%{} = attrs) do
    seq = Sequence.next("")

    %{
      title: Sequence.next("Resume "),
      description: Enum.random([nil, Faker.Lorem.Shakespeare.En.as_you_like_it()]),
      experiences: experiences(Enum.random(@one_nil), seq),
      personal_info: personal_info(Enum.random(@one_nil), seq),
      education: education(Enum.random(@one_nil), seq),
      additional_skills: additional_skills(Enum.random(@one_nil), seq),
      languages: languages(Enum.random(@one_nil), seq)
    }
    |> Map.merge(attrs)
    |> Factory.reject_attrs()
  end

  defp experiences(nil, _) do
    nil
  end

  defp experiences(_, seq) do
    [
      %{
        company_name: "Company " <> seq,
        from_date: "03/2015",
        position: "Position " <> seq,
        to_date: Enum.random([nil, "04/2016"]),
        achievements:
          Enum.random([
            nil,
            ["Experience achievement " <> seq <> Faker.Lorem.sentence()]
          ])
      }
    ]
  end

  defp personal_info(nil, _), do: nil

  defp personal_info(_, seq) do
    %{
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      address: Faker.Address.street_address(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone(),
      profession: "Profession " <> seq
    }
  end

  defp education(nil, _), do: nil

  defp education(_, seq) do
    [
      %{
        achievements: ["Education achievement " <> seq],
        course: "Course " <> seq,
        from_date: "03/2000",
        school: "School " <> seq,
        to_date: "04/2004"
      }
    ]
  end

  defp additional_skills(nil, _), do: nil

  defp additional_skills(_, seq) do
    [
      %{
        description: "Additional Skill " <> seq,
        level: Enum.random(1..5) |> to_string()
      }
    ]
  end

  defp languages(nil, _), do: nil

  defp languages(_, seq) do
    [
      %{
        description: "Language " <> seq,
        level: Enum.random(1..5) |> to_string()
      }
    ]
  end

  def stringify(%{} = params) do
    params
    |> Factory.reject_attrs()
    |> Enum.map(fn
      {k, v} ->
        {Factory.to_camel_key(k), stringifyp(v)}
    end)
    |> Enum.into(%{})
  end

  defp stringifyp(attrs) when is_list(attrs) do
    Enum.map(attrs, &stringifyp/1)
  end

  defp stringifyp(%{} = attrs) do
    attrs
    |> Factory.reject_attrs()
    |> Enum.map(fn
      {k, v} when is_list(v) ->
        {Factory.to_camel_key(k), stringifyp(v)}

      {k, v} ->
        {Factory.to_camel_key(k), v}
    end)
    |> Enum.into(%{})
  end

  defp stringifyp(val), do: val
end
