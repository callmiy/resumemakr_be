defmodule Data.Repo.Migrations.CreateRated do
  use Ecto.Migration

  def change do
    create table(:ratable, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add :description, :citext, null: false
      add :level, :string

      timestamps(type: :utc_datetime)
    end
  end
end
