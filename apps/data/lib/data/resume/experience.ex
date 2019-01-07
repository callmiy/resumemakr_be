defmodule Data.Resumes.Experience do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  schema "experiences" do
    belongs_to(:resume, Resume)
    field :achievements, {:array, :string}
    field :company_name, :string
    field :from_date, :string
    field :position, :string
    field :to_date, :string
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [
      :resume_id,
      :position,
      :company_name,
      :from_date,
      :to_date,
      :achievements
    ])
    |> validate_required([
      :resume_id,
      :position,
      :company_name,
      :from_date
    ])
  end
end
