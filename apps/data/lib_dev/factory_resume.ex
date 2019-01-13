defmodule Data.FactoryResume do
  use Data.Factory

  alias Data.Factory
  alias Data.Resumes

  @one_nil [1, nil]

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
      languages: languages(Enum.random(@one_nil), seq),
      skills: skills(Enum.random(@one_nil), seq),
      hobbies: Enum.random([nil, ["Hobby " <> seq]])
    }
    |> Map.merge(attrs)
    |> Factory.reject_attrs()
  end

  def experiences(nil, _) do
    nil
  end

  def experiences(_, seq) do
    [
      %{
        index: 1,
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

  def personal_info(nil, _), do: nil

  def personal_info(_, seq) do
    %{
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      address: Faker.Address.street_address(),
      email: Faker.Internet.email(),
      phone: Faker.Phone.EnUs.phone(),
      profession: "Profession " <> seq,
      photo:
        Enum.random([
          nil,
          photo_plug(),
          # if "nil", then we do not want to delete the photo key in stringify/2
          "nil"
        ])
    }
  end

  def photo_plug do
    %Plug.Upload{
      content_type: "image/png",
      filename: "dog.jpeg",
      path: Path.join([Data.app_root(), "priv/test-files", "dog.jpeg"])
    }
  end

  def education(nil, _), do: nil

  def education(_, seq) do
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

  def skills(nil, _) do
    nil
  end

  def skills(_, seq) do
    [
      %{
        description: "Skill " <> seq,
        achievements:
          Enum.random([
            nil,
            ["Skill achievement " <> seq <> Faker.Lorem.sentence()]
          ])
      }
    ]
  end

  def stringify(%{} = params) do
    params
    |> Enum.map(fn
      {k, %Plug.Upload{} = v} ->
        {Factory.to_camel_key(k), v}

      {k, v} ->
        {Factory.to_camel_key(k), stringify(v)}
    end)
    |> Enum.into(%{})
  end

  def stringify(attrs) when is_list(attrs) do
    Enum.map(attrs, &stringify(&1))
  end

  def stringify(val), do: val
end
