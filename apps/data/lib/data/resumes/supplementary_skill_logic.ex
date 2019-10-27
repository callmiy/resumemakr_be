defmodule Data.Resumes.SupplementarySkillLogic do
  @moduledoc """
  Logic related to supplementary skill
  """

  alias Data.Repo
  alias Data.Resumes.SupplementarySkill

  @spec create_supplementary_skill(attrs :: map) ::
          {:ok, SupplementarySkill.t()} | {:error, Ecto.Changeset.t()}
  def create_supplementary_skill(attrs) do
    %SupplementarySkill{}
    |> SupplementarySkill.changeset(attrs)
    |> Repo.insert()
  end
end
