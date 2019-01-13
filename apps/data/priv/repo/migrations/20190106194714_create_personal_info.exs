defmodule Xx.Repo.Migrations.CreatePersonalInfo do
  use Ecto.Migration

  def change do
    create table(:personal_info) do
      add :first_name, :string
      add :last_name, :string
      add :profession, :string
      add :address, :text
      add :email, :string
      add :phone, :string
      add :photo, :string
      add :date_of_birth, :string

      add :resume_id,
          references(:resumes, on_delete: :delete_all),
          null: false,
          comment: "The resume"
    end

    :personal_info
    |> index([:resume_id])
    |> create()
  end
end
