defmodule Data.Resumes.RatableLogic do
  @moduledoc """
  Logic related to spoken language
  """

  alias Data.Repo
  alias Data.Resumes.SpokenLanguage
  alias Data.Resumes.SupplementarySkill

  @spec create_ratable(
          ratable_type :: Atom.t(),
          attrs :: map
        ) ::
          {:error, Ecto.Changeset.t()}
          | {
              :ok,
              SpokenLanguage.t() | SupplementarySkill.t()
            }
  def create_ratable(:spoken_language, attrs) do
    %SpokenLanguage{}
    |> SpokenLanguage.changeset(attrs)
    |> Repo.insert()
  end

  def create_ratable(:supplementary_skill, attrs) do
    %SupplementarySkill{}
    |> SupplementarySkill.changeset(attrs)
    |> Repo.insert()
  end
end
