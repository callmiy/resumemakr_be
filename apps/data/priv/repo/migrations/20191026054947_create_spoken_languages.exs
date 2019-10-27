defmodule Data.Repo.Migrations.CreateSpokenLanguages do
  use Ecto.Migration

  def change do
    create table(
             :spoken_languages,
             options: "INHERITS (rated)",
             primary_key: false
           ) do
      add :resume_id,
          references(
            :resumes,
            on_delete: :delete_all,
            type: :binary_id
          ),
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
