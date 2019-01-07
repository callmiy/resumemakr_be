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
    embeds_many(:languages, Rated)
    embeds_many(:additional_skills, Rated)
    belongs_to(:user, User)

    has_one(:personal_info, PersonalInfo)
    has_many(:education, Education)
    has_many(:skills, Skill)
    has_many(:experiences, Experience)

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [:title, :user_id])
    |> cast_embed(:languages)
    |> cast_embed(:additional_skills)
    |> validate_required([:title, :user_id])
    |> assoc_constraint(:user)
  end

  def my_fields do
    [:title, :user_id, :languages, :additional_skills, :description]
  end
end
