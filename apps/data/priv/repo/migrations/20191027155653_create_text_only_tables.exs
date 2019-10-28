defmodule Data.Repo.Migrations.CreateTextOnlyTables do
  use Ecto.Migration

  @start_path Path.expand("")
  @relative_path "priv/repo/20191027170558_data_migrate_embedded_text_only.exs"
  @app_path "apps/data"

  case String.ends_with?(@start_path, @app_path) do
    true ->
      @relative_path

    _ ->
      "#{@app_path}/#{@relative_path}"
  end
  |> Code.compile_file()

  alias Data.Repo.Migrations.DataMigrateEmbeddedTextOnly

  @achieving_tables [
    "education",
    "experiences",
    "skills"
  ]

  def up do
    Enum.each(@achieving_tables, fn assoc_table ->
      create_text_only_table(assoc_table, "achievements")
    end)

    create_text_only_table("resumes", "hobbies")

    flush()

    Enum.each(
      @achieving_tables,
      fn assoc_table ->
        DataMigrateEmbeddedTextOnly.up_achieving_tables(assoc_table)
        drop_embedded_columns(assoc_table, :achievements)
      end
    )

    DataMigrateEmbeddedTextOnly.up_hobbies()
    drop_embedded_columns("resumes", :hobbies)
  end

  def down do
    Enum.each(@achieving_tables, fn assoc_table ->
      create_embedded_columns(assoc_table, :achievements)
    end)

    create_embedded_columns("resumes", :hobbies)

    flush()

    Enum.each(@achieving_tables, fn assoc_table ->
      DataMigrateEmbeddedTextOnly.down(assoc_table, :achievements)
    end)

    DataMigrateEmbeddedTextOnly.down("resumes", :hobbies)

    Enum.each(@achieving_tables, fn assoc_table ->
      drop_text_only_table(assoc_table, "achievements")
    end)

    drop_text_only_table("resumes", "hobbies")
  end

  defp create_text_only_table(assoc_table, suffix) do
    table = compute_table_name(assoc_table, suffix)

    create table(table, primary_key: false) do
      add(:id, :binary_id, primary_key: true, null: false)
      add(:text, :text, null: false)

      add(
        :owner_id,
        references(
          assoc_table,
          on_delete: :delete_all,
          type: :binary_id
        ),
        null: false
      )
    end

    table
    |> index([:owner_id])
    |> create()
  end

  defp drop_text_only_table(assoc_table, suffix) do
    compute_table_name(assoc_table, suffix)
    |> table()
    |> drop()
  end

  defp compute_table_name(assoc_table, suffix) do
    "#{assoc_table}_#{suffix}"
  end

  defp drop_embedded_columns(assoc_table, suffix) do
    alter table(assoc_table) do
      remove(suffix)
    end
  end

  defp create_embedded_columns(assoc_table, suffix) do
    alter table(assoc_table) do
      add(suffix, {:array, :text})
    end
  end
end
