defmodule Data.Resumes.Education do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  schema "education" do
    belongs_to(:resume, Resume)
    field :course, :string
    field :from_date, :string
    field :school, :string
    field :to_date, :string
    field :achievements, {:array, :string}
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
      :achievements
    ])
    |> validate_required([:resume_id, :school, :course, :from_date])
  end
end
