defmodule Data.Resumes.Rated do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :description, :string
    field :level, :string
  end

  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [:description, :level])
    |> validate_required([:description])
  end
end
