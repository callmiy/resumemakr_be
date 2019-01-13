defmodule Data.Resumes.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes

  schema "skills" do
    belongs_to(:resume, Resume)
    field :achievements, {:array, :string}
    field :description, :string
    field :delete, :boolean, virtual: true
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [
      :description,
      :achievements,
      :resume_id,
      :delete
    ])
    # |> validate_required([:description])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end
end
