defmodule Data.Resolver.SpokenLanguage do
  alias Data.Resumes
  alias Data.Resumes.SpokenLanguage
  alias Data.Accounts.User

  @spec create(
          %{input: map},
          %{context: %{current_user: User.t()}}
        ) :: {:error, Ecto.Changeset.t()} | {:ok, SpokenLanguage.t()}
  def create(%{input: args}, %{context: %{current_user: _user}}) do
    Resumes.create_spoken_language(args)
  end
end
