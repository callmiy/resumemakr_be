defmodule Data.Repo.Migrations.CreateSpokenLanguages do
  use Ecto.Migration

  @start_path Path.expand("")
  @relative_path "priv/repo/20191027091600_data_migrate_embedded_to_tables.exs"
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
    up_spoken_language_schema()
    up_supplementary_skill_schema()

    flush()

    DataMigrateLanguagesToSpoken.migrate_to_tables()

    :resumes
    |> index([:languages], name: "resumes_languages")
    |> drop()

    :resumes
    |> index([:additional_skills], name: "resumes_additional_skills")
    |> drop()

    alter table("resumes") do
      remove(:languages)
      remove(:additional_skills)
    end
  end

  def down do
    alter table("resumes") do
      add(:languages, :jsonb)
      add(:additional_skills, :jsonb)
    end

    execute "CREATE INDEX resumes_languages ON resumes USING GIN (languages);"

    execute "CREATE INDEX resumes_additional_skills ON resumes USING GIN (additional_skills);"

    flush()

    DataMigrateLanguagesToSpoken.migrate_to_embedded(
      "spoken_languages",
      :languages
    )

    DataMigrateLanguagesToSpoken.migrate_to_embedded(
      "supplementary_skills",
      :additional_skills
    )

    "spoken_languages"
    |> table()
    |> drop()

    "supplementary_skills"
    |> table()
    |> drop()
  end

  defp up_spoken_language_schema do
    create table(
             :spoken_languages,
             options: "INHERITS (ratable)",
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
  end

  defp up_supplementary_skill_schema do
    create table(
             :supplementary_skills,
             options: "INHERITS (ratable)",
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

    :supplementary_skills
    |> index([:resume_id])
    |> create()

    :supplementary_skills
    |> unique_index([:description, :resume_id])
    |> create()
  end
end
