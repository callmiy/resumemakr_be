defmodule Data.Repo.Migrations.DataMigrateEmbeddedTextOnly do
  import Ecto.Query
  alias Data.Repo

  def up_achieving_tables(assoc_table) do
    data =
      from(
        e in assoc_table,
        select: %{
          id: e.id,
          achievements: e.achievements
        }
      )
      |> Repo.all()
      |> Enum.flat_map(fn data ->
        Enum.map(data.achievements || [], fn achievement ->
          %{
            text: achievement,
            owner_id: data.id,
            id: Ecto.ULID.bingenerate()
          }
        end)
      end)

    Repo.insert_all("#{assoc_table}_achievements", data)
  end

  def up_hobbies do
    data =
      from(
        e in "resumes",
        select: %{
          id: e.id,
          hobbies: e.hobbies
        }
      )
      |> Repo.all()
      |> Enum.flat_map(fn data ->
        Enum.map(data.hobbies || [], fn hobbies ->
          %{
            text: hobbies,
            owner_id: data.id,
            id: Ecto.ULID.bingenerate()
          }
        end)
      end)

    Repo.insert_all("resumes_hobbies", data)
  end

  def down(assoc_table, suffix) do
    table_name = "#{assoc_table}_#{suffix}"

    from(
      t in table_name,
      select: %{
        owner_id: t.owner_id,
        text: t.text
      }
    )
    |> Repo.all()
    |> Enum.group_by(& &1.owner_id)
    |> Enum.each(fn {owner_id, data} ->
      update_values = [
        {suffix, data.text}
      ]

      from(
        a in assoc_table,
        where: a.id == ^owner_id,
        update: [
          set: ^update_values
        ]
      )
      |> Repo.update_all([])
    end)
  end
end
