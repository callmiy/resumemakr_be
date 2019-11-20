defmodule Data.Repo.Migrations.AddResumeRatedIndex do
  use Ecto.Migration
  import Ecto.Query
  alias Data.Repo

  def change do
    from(
      r in "resumes",
      select: {
        r.id,
        [
          {:additional_skills, r.additional_skills},
          {:languages, r.languages}
        ]
      }
    )
    |> Repo.all()
    |> Enum.each(fn {resume_id, attrs_for_update} ->
      attrs_for_update_with_indices =
        Enum.reduce(attrs_for_update, [], fn
          {_, []}, acc ->
            acc

          {k, v}, acc ->
            values_with_indices =
              v
              |> Enum.with_index(1)
              |> Enum.map(fn
                {v, index} ->
                  Map.put(v, :index, index)
              end)

            [
              {k, values_with_indices} | acc
            ]
        end)
        |> case do
          [] ->
            :ok

          attrs_for_update_with_indices ->
            from(
              r in "resumes",
              where: r.id == ^resume_id,
              update: [
                set: ^attrs_for_update_with_indices
              ]
            )
            |> Repo.update_all([])
        end
    end)
  end
end
