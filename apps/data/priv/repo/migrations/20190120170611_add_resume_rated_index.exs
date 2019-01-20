defmodule Data.Repo.Migrations.AddResumeRatedIndex do
  use Ecto.Migration

  def change do
    Data.Resumes.Resume
    |> Data.Repo.all()
    |> Enum.map(fn r ->
      case r
           |> Map.take([:additional_skills, :languages])
           |> Enum.reduce(%{}, fn
             {k, []}, acc ->
               acc

             {k, v}, acc ->
               updated_with_index =
                 v
                 |> Enum.with_index(1)
                 |> Enum.map(fn {d, index} ->
                   d
                   |> Map.from_struct()
                   |> Map.put(:index, index)
                 end)

               Map.put(acc, k, updated_with_index)
           end) do
        update when update == %{} ->
          :ok

        update ->
          Data.Resumes.update_resume(r, update)
      end
    end)
  end
end
