defmodule Data.ResumeFactory do
  use Data.Factory

  alias Data.Factory
  alias Data.Resumes

  @one_nil [1, nil]

  @dog_img_file_upload Path.join(Data.app_root(), "priv/test-files/dog.jpeg")
                       |> Data.file_to_data_uri("image/jpeg")

  def insert(attrs) do
    attrs = params(attrs)

    attrs = parse_photo(attrs)

    {:ok, resume} = Resumes.create_resume(attrs)
    resume
  end

  def insert_minimal(attrs) do
    attrs = params_minimal(attrs)
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
      skills: skills(Enum.random(@one_nil), seq),
      hobbies: Enum.random([nil, ["Hobby " <> seq]])
    }
    |> Map.merge(attrs)
    |> Factory.reject_attrs()
  end

  def params_minimal(%{user_id: _} = attrs) do
    %{
      title: Sequence.next("Resume ")
    }
    |> Map.merge(attrs)
  end

  def params_minimal(attrs) when is_list(attrs) do
    attrs
    |> Map.new()
    |> params_minimal()
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
    @dog_img_file_upload
  end

  def education(nil, _), do: nil

  def education(_, seq) do
    [
      %{
        index: 1,
        achievements: ["Education achievement " <> seq],
        course: "Course " <> seq,
        from_date: "03/2000",
        school: "School " <> seq,
        to_date: "04/2004"
      }
    ]
  end

  def skills(nil, _) do
    nil
  end

  def skills(_, seq) do
    [
      %{
        index: 1,
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

  def parse_photo(%{personal_info: %{photo: photo}} = attrs) do
    case Data.plug_from_base64(photo) do
      {:ok, plug} ->
        update_in(attrs.personal_info.photo, fn _ -> plug end)

      _ ->
        attrs
    end
  end

  def parse_photo(attrs), do: attrs
end
