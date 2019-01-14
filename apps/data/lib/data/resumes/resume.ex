defmodule Data.Resumes.Resume do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Accounts.User
  alias Data.Resumes.Education
  alias Data.Resumes.Skill
  alias Data.Resumes.Experience
  alias Data.Resumes.PersonalInfo
  alias Data.Resumes.Rated

  schema "resumes" do
    field(:title, :string)
    field(:description, :string)
    field(:hobbies, {:array, :string})

    embeds_many(:languages, Rated)
    embeds_many(:additional_skills, Rated)

    belongs_to(:user, User)

    has_one(:personal_info, PersonalInfo)
    has_many(:education, Education)
    has_many(:skills, Skill)
    has_many(:experiences, Experience)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = schema), do: changeset(schema, %{})
  def changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [:title, :user_id, :description, :hobbies])
    |> cast_embed(:languages, required: false)
    |> cast_embed(:additional_skills, required: false)
    |> cast_assoc(:personal_info, with: &PersonalInfo.changeset/2)
    |> cast_assoc(:experiences, with: &Experience.changeset/2)
    |> cast_assoc(:education, with: &Education.changeset/2)
    |> cast_assoc(:skills, with: &Skill.changeset/2)
    |> validate_required([:title, :user_id])
    |> unique_constraint(:title, name: :resumes_user_id_title_index)
    |> assoc_constraint(:user)
  end

  def assoc_fields do
    [:personal_info, :education, :skills, :experiences]
  end
end
