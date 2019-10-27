defmodule Data.Repo.Migrations.DataMigrateLanguagesToSpoken do
  import Ecto.Query
  alias Data.Repo

  defp get_languages_from_resumes do
    from(
      r in "resumes",
      select: %{
        id: r.id,
        languages: r.languages,
        inserted_at: r.inserted_at,
        updated_at: r.updated_at
      }
    )
    |> Repo.all()
    |> Enum.flat_map(fn resume ->
      (resume.languages || [])
      |> Enum.sort(&(&1["index"] <= &2["index"]))
      |> Enum.map(fn language ->
        language
        |> Map.take(["description", "level"])
        |> Map.merge(%{
          "resume_id" => resume.id,
          "inserted_at" => resume.inserted_at,
          "updated_at" => resume.updated_at,
          "id" => Ecto.ULID.bingenerate()
        })
      end)
    end)
  end

  def migrate_spoken_languages_to_languages do
    from(
      s in "spoken_languages",
      select: %{
        id: s.id,
        description: s.description,
        level: s.level,
        resume_id: s.resume_id
      }
    )
    |> Repo.all()
    |> Enum.group_by(& &1.resume_id)
    |> Enum.map(fn {resume_id, spoken_languages} ->
      languages_to_insert =
        Enum.with_index(spoken_languages, 1)
        |> Enum.map(fn {spoken, index} ->
          spoken
          |> Map.take([:description, :level])
          |> Map.merge(%{
            index: index,
            id: Ecto.UUID.cast!(spoken.id)
          })
        end)

      from(
        r in "resumes",
        where: r.id == ^resume_id,
        update: [
          set: [
            languages: ^languages_to_insert
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  def migrate_languages_to_spoken_languages do
    Repo.insert_all("spoken_languages", get_languages_from_resumes())
  end
end
