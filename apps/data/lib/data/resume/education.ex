defmodule Data.Resumes.Education do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes

  schema "education" do
    belongs_to(:resume, Resume)
    field :course, :string
    field :from_date, :string
    field :school, :string
    field :to_date, :string
    field :achievements, {:array, :string}
    field :delete, :boolean, virtual: true
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
      :achievements,
      :delete
    ])
    # |> validate_required([:school, :course, :from_date])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end
end
