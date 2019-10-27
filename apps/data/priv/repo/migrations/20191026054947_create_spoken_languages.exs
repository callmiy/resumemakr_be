defmodule Data.Repo.Migrations.CreateSpokenLanguages do
  use Ecto.Migration

  @start_path Path.expand("")
  @relative_path "priv/repo/20191027091600_data_migrate_languages_to_spoken.exs"
  @app_path "apps/data"

  case String.ends_with?(@start_path, @app_path) do
    true ->
      @relative_path

    _ ->
      "#{@app_path}/#{@relative_path}"
  end
  |> Code.compile_file()

  alias Data.Repo.Migrations.DataMigrateLanguagesToSpoken

  def up do
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
          null: false
    end

    :spoken_languages
    |> index([:resume_id])
    |> create()

    :spoken_languages
    |> unique_index([:description, :resume_id])
    |> create()

    flush()

    DataMigrateLanguagesToSpoken.migrate_languages_to_spoken_languages()

    alter table("resumes") do
      remove(:languages)
    end
  end

  def down do
    alter table("resumes") do
      add(:languages, :jsonb)
    end

    execute "CREATE INDEX resumes_languages_index ON resumes USING GIN (languages);"

    flush()

    DataMigrateLanguagesToSpoken.migrate_spoken_languages_to_languages()

    "spoken_languages"
    |> table()
    |> drop()
  end
end
