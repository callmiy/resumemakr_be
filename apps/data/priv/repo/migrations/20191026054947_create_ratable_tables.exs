defmodule Data.Repo.Migrations.CreateRatableTables do
  use Ecto.Migration

  @start_path Path.expand("")
  @relative_path "priv/repo/20191027091600_data_migrate_ratables.exs"
  @app_path "apps/data"

  case String.ends_with?(@start_path, @app_path) do
    true ->
      @relative_path

    _ ->
      "#{@app_path}/#{@relative_path}"
  end
  |> Code.compile_file()

  alias Data.Repo.Migrations.DataMigrateRatables

  def up do
    create_ratable_table(:spoken_languages)
    create_ratable_table(:supplementary_skills)

    flush()

    DataMigrateRatables.migrate_to_ratables()

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

    DataMigrateRatables.migrate_to_embedded(
      "spoken_languages",
      :languages
    )

    DataMigrateRatables.migrate_to_embedded(
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

  defp create_ratable_table(table_name) do
    create table(table_name, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add :description, :citext, null: false
      add :level, :string

      add(
        :owner_id,
        references(
          :resumes,
          on_delete: :delete_all,
          type: :binary_id
        ),
        null: false
      )

      timestamps(type: :timestamptz)
    end

    table_name
    |> index([:owner_id])
    |> create()

    table_name
    |> unique_index([:description, :owner_id])
    |> create()
  end
end
