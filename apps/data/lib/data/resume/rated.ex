defmodule Data.Resumes.Rated do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes

  # @primary_key false
  embedded_schema do
    field :description, :string
    field :level, :string
    field :delete, :boolean, virtual: true
  end

  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [:description, :level])
    |> validate_required([:description])
    |> Resumes.maybe_mark_for_deletion()
  end
end
