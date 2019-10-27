defmodule DataMigrateLanguage do
  alias Data.Repo
  alias Data.Resumes.Resume
  alias Data.Resumes

  def migrate do
    Resume
    |> Repo.all()
    |> Enum.map(fn resume ->
      languages =
        (resume.languages || [])
        |> Enum.sort(&(&1.index <= &2.index))
        |> Enum.map(fn language ->
          {:ok, _} = Resumes.create_spoken_language(language)
        end)
    end)
  end
end
