defmodule Data.ResolverResume do
  alias Data.Resolver
  alias Data.Resumes
  alias Data.Resumes.Resume

  @spec create(
          any(),
          map(),
          %{context: %{current_user: atom() | %{id: any()}}}
        ) :: {:error, binary()} | {:ok, %Resume{}}
  def create(_, attrs, %{context: %{current_user: user}}) do
    case attrs
         |> Map.put(:user_id, user.id)
         |> Resumes.create_resume() do
      {:ok, resume} ->
        {:ok, %{resume: resume}}

      {:error, failed_operations, changeset} ->
        {:error,
         Resolver.transaction_errors_to_string(
           changeset,
           failed_operations
         )}
    end
  end

  @spec resumes(
          %{
            after: nil | integer(),
            before: nil | integer(),
            first: nil | integer(),
            last: nil | integer()
          },
          %{context: %{current_user: atom() | %{id: any()}}}
        ) ::
          {:error, <<_::64, _::_*8>>}
          | {:ok,
             %{
               edges: [map()],
               page_info: %{
                 end_cursor: binary(),
                 has_next_page: boolean(),
                 has_previous_page: boolean(),
                 start_cursor: binary()
               }
             }}
  def resumes(pagination_args, %{context: %{current_user: user}}) do
    Resumes.list_resumes(user.id, pagination_args)
  end
end
