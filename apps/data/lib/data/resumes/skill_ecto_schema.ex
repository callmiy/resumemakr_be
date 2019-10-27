defmodule Data.Resumes.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes
  alias Data.Resumes.TextOnly

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "skills" do
    belongs_to(:resume, Resume)
    field :description, :string
    field :index, :integer
    field :delete, :boolean, virtual: true

    has_many(
      :achievements,
      {"skills_achievements", TextOnly},
      foreign_key: :owner_id
    )
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [
      :description,
      :resume_id,
      :delete,
      :index
    ])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end
end
