defmodule Data.Resumes.SpokenLanguageLogic do
  @moduledoc """
  Logic related to spoken language
  """

  alias Data.Repo
  alias Data.Resumes.SpokenLanguage

  @spec create_spoken_language(attrs :: map) ::
          {:ok, SpokenLanguage.t()} | {:error, Ecto.Changeset.t()}
  def create_spoken_language(attrs) do
    %SpokenLanguage{}
    |> SpokenLanguage.changeset(attrs)
    |> Repo.insert()
  end
end
