defmodule Data.Resumes.TextOnly do
  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "abstract table: only_texts" do
    field :text, :string
    field :owner_id, Ecto.ULID
  end
end
