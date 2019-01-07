defmodule Data.Resumes.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  schema "skills" do
    belongs_to(:resume, Resume)
    field :achievements, :string
    field :description, :string
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:description, :achievements])
    |> validate_required([:description, :achievements])
  end
end
