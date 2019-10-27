defmodule Data.Resumes.SpokenLanguage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "spoken_languages" do
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
      name: :languages_description_resume_id_index
    )
  end
end
