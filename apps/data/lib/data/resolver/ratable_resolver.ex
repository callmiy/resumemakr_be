defmodule Data.Resolver.RatableResolver do
  alias Data.Resumes
  alias Data.Resumes.SpokenLanguage
  alias Data.Resumes.SupplementarySkill
  alias Data.Accounts.User
  alias Data.Resumes.Resume

  @spec create(
          %{input: map},
          %{context: %{current_user: User.t()}}
        ) ::
          {:error, Ecto.Changeset.t()}
          | {
              :ok,
              SpokenLanguage.t() | SupplementarySkill.t()
            }
  def create(
        %{
          input:
            %{
              resume_id: resume_id,
              ratable_type: ratable_type
            } = args
        },
        %{context: %{current_user: %{id: user_id}}}
      ) do
    case Resumes.get_resume_by(%{
           id: resume_id,
           user_id: user_id
         }) do
      %Resume{} ->
        Resumes.create_ratable(ratable_type, args)
    end
  end
end
