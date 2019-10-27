defmodule Data.Resumes.Education do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes
  alias Data.Resumes.TextOnly

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "education" do
    belongs_to(:resume, Resume)
    field :course, :string
    field :from_date, :string
    field :school, :string
    field :to_date, :string
    field :index, :integer
    field :delete, :boolean, virtual: true

    has_many(
      :achievements,
      {"education_achievements", TextOnly},
      foreign_key: :owner_id
    )
  end

  @doc false
  def changeset(education, attrs) do
    education
    |> cast(attrs, [
      :resume_id,
      :school,
      :course,
      :from_date,
      :to_date,
      :delete,
      :index
    ])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end
end
