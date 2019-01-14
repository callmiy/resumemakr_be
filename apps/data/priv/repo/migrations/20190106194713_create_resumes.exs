defmodule Data.Repo.Migrations.CreateResumeTitles do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;")

    create table(:resumes) do
      add :title, :citext, null: false
      add :description, :text
      add :languages, :jsonb
      add :additional_skills, :jsonb
      add :hobbies, {:array, :text}

      add :user_id,
          references(:users, on_delete: :delete_all),
          null: false,
          comment: "The owner of the resume"

      timestamps(type: :utc_datetime)
    end

    :resumes
    |> index([:user_id])
    |> create()

    :resumes
    |> unique_index([:user_id, :title])
    |> create()

    execute "CREATE INDEX resumes_languages ON resumes USING GIN (languages);"

    execute "CREATE INDEX resumes_additional_skills ON resumes USING GIN (additional_skills);"
  end
end
