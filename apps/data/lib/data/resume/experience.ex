defmodule Data.Resumes.Experience do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes

  schema "experiences" do
    belongs_to(:resume, Resume)
    field :achievements, {:array, :string}
    field :company_name, :string
    field :from_date, :string
    field :position, :string
    field :to_date, :string
    field :delete, :boolean, virtual: true
  end

  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, [
      :resume_id,
      :position,
      :company_name,
      :from_date,
      :to_date,
      :achievements,
      :delete
    ])
    |> validate_required([
      :position,
      :company_name,
      :from_date
    ])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end
end
