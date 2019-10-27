defmodule Data.Resumes.TextOnlyLogic do
  alias Data.Repo

  def create_text_only(:resumes_hobbies, attrs) do
    attrs.resume
    |> Ecto.build_assoc(:hobbies, attrs)
    |> Repo.insert()
  end
end
