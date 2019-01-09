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
        {:ok, wrapped(resume)}

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

  def update(args, %{context: %{current_user: user}}) do
    {id, new_args} = Map.pop(args, :id)
    user_id = user.id

    case Resumes.get_resume_by(id: id, user_id: user_id) do
      nil ->
        {:error, "Resume does not exist"}

      resume ->
        case Resumes.update_resume(
               resume,
               Map.put(new_args, :user_id, user_id)
             ) do
          {:ok, updated_resume} ->
            {:ok, wrapped(updated_resume)}
        end
    end
  end

  defp wrapped(%Resume{} = resume) do
    associates =
      resume
      |> Map.take([:personal_info, :education, :experiences])
      |> Enum.map(fn
        {:personal_info, %Ecto.Association.NotLoaded{}} ->
          {:personal_info, nil}

        {k, %Ecto.Association.NotLoaded{}} ->
          {k, []}

        v ->
          v
      end)
      |> Enum.into(%{})

    %{resume: Map.merge(resume, associates)}
  end
end
