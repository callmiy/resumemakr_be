defmodule Data.Resumes.TextOnlyLogic do
  alias Data.Repo

  def create_text_only(%{tag: :resumes_hobbies} = attrs) do
    attrs.resume
    |> Ecto.build_assoc(:hobbies, attrs)
    |> Repo.insert()
  end

  def create_text_only(%{tag: :education_achievements} = attrs) do
    attrs.education
    |> Ecto.build_assoc(:achievements, attrs)
    |> Repo.insert()
  end
end
