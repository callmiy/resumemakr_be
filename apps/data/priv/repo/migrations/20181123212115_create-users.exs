defmodule EbData.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string, null: false)
      add(:email, :string, null: false)

      timestamps(type: :utc_datetime)
    end

    :users
    |> unique_index([:email])
    |> create()
  end
end
