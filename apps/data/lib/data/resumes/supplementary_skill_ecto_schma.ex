defmodule Data.Resumes.SupplementarySkill do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "supplementary_skills" do
    field :description, :string
    field :level, :string
    belongs_to :resume, Resume

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [:description, :level, :resume_id])
    |> unique_constraint(
      :description,
      name: :supplementary_skills_description_resume_id_index
    )
  end
end
