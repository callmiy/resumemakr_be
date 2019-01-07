defmodule Data.ResolverResume do
  alias Data.Resolver
  alias Data.Resumes

  def create(_, %{resume: attrs}, %{context: %{current_user: user}}) do
    case attrs
         |> Map.put(:user_id, user.id)
         |> Resumes.create_resume() do
      {:ok, resume} ->
        {:ok, resume}

      {:error, failed_operations, changeset} ->
        {:error,
         Resolver.transaction_errors_to_string(
           changeset,
           failed_operations
         )
        }
    end
  end
end
