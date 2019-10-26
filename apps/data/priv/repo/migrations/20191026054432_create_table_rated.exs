defmodule Data.Repo.Migrations.CreateTableRated do
  use Ecto.Migration

  def change do
    create table(:rated) do
      add :description, :citext, null: false
      add :level, :string

      timestamps(type: :utc_datetime)
    end
  end
end
