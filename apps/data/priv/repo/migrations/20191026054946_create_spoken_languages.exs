defmodule Data.Repo.Migrations.CreateSpokenLanguages do
  use Ecto.Migration

  def change do
    create table(:spoken_languages, options: "INHERITS (rated)") do
      add :resume_id,
          references(:resumes, on_delete: :delete_all),
          null: false,
          comment: "The resume"
    end


    :spoken_languages
    |> index([:resume_id])
    |> create()

    :spoken_languages
    |> unique_index([:description, :resume_id])
    |> create()
  end
end
