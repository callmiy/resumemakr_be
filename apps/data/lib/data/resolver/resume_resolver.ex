defmodule Data.ResumeResolver do
  import Absinthe.Relay.Node, only: [from_global_id: 2]
  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Data.Resolver
  alias Data.Resumes
  alias Data.Resumes.Resume
  alias Data.Resumes.PersonalInfo
  alias Data.Uploaders.ResumePhoto

  @fields_to_sanitize Resume.assoc_fields() ++ [:languages, :additional_skills]

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
        {:error, "Resume you are updating does not exist"}

      resume ->
        case Resumes.update_resume(resume, new_args) do
          {:ok, updated_resume} ->
            {:ok, wrapped(updated_resume)}

          {:error, changeset} ->
            {
              :error,
              changeset.errors
              |> Resolver.errors_to_map()
              |> Jason.encode!()
            }
        end
    end
  end

  def delete(%{id: id}, %{context: %{current_user: user}}) do
    case Resumes.get_resume_by(id: id, user_id: user.id) do
      nil ->
        {:error, "Resume you are deleting does not exist"}

      resume ->
        case Resumes.delete_resume(resume) do
          {:ok, deleted_resume} ->
            {:ok, wrapped(deleted_resume)}

          {:error, changeset} ->
            {
              :error,
              changeset.errors
              |> Resolver.errors_to_map()
              |> Jason.encode!()
            }
        end
    end
  end

  def get_resume(attrs) do
    case Resumes.get_resume_by(attrs) do
      %Resume{} = resume ->
        {:ok, sanitize_children(resume)}

      nil ->
        {:error, "resume not found"}
    end
  end

  def get_resume(%{input: attrs}, %{context: %{current_user: user}}) do
    case Map.has_key?(attrs, :id) || Map.has_key?(attrs, :title) do
      true ->
        attrs
        |> convert_from_global()
        |> Map.put(:user_id, user.id)
        |> get_resume()

      false ->
        {:error, "invalid query arguments"}
    end
  end

  def clone(inputs, %{context: %{current_user: user}}) do
    {id, attrs} = Map.pop(inputs, :id)

    case Resumes.get_resume_by(id: id, user_id: user.id) do
      nil ->
        {:error, "Resume you are trying to clone does not exist"}

      resume ->
        case Resumes.clone_resume(resume, attrs) do
          {:ok, cloned_resume} ->
            {:ok, wrapped(cloned_resume)}

          {:error, changeset} ->
            {
              :error,
              changeset.errors
              |> Resolver.errors_to_map()
              |> Jason.encode!()
            }
        end
    end
  end

  defp to_string_photo(%PersonalInfo{} = personal_info) do
    case personal_info.photo do
      nil ->
        personal_info

      %{file_name: file_name} ->
        Map.put(
          personal_info,
          :photo,
          ResumePhoto.url({file_name, personal_info})
        )

      _ ->
        personal_info
    end
  end

  defp to_string_photo(nil) do
    nil
  end

  defp to_string_photo(personal_info) do
    personal_info
  end

  def get_assoc(key) do
    fn root, _, %{context: %{loader: loader}} ->
      case Map.get(root, key) do
        %Ecto.Association.NotLoaded{} ->
          loader
          |> Dataloader.load(:data, key, root)
          |> on_load(fn data_source ->
            assoc = Dataloader.get(data_source, :data, key, root)
            {:ok, sanitize_child(key, assoc)}
          end)

        assoc ->
          {:ok, sanitize_child(key, assoc)}
      end
    end
  end

  def sanitize_child(:personal_info, child), do: to_string_photo(child)

  def sanitize_child(_, child) when is_list(child),
    do: Enum.sort_by(child, & &1.index)

  def sanitize_child(_, child), do: child

  defp sanitize_children(%Resume{} = resume) do
    children =
      resume
      |> Map.take(@fields_to_sanitize)
      |> Enum.map(fn {k, v} -> {k, sanitize_child(k, v)} end)
      |> Enum.into(%{})

    Map.merge(resume, children)
  end

  defp wrapped(%Resume{} = resume) do
    %{resume: sanitize_children(resume)}
  end

  defp convert_from_global(%{id: id} = attrs) do
    case from_global_id(id, Data.Schema) do
      {:ok, %{id: internal_id, type: :resume}} ->
        Map.put(attrs, :id, internal_id)

      _ ->
        attrs
    end
  end

  defp convert_from_global(attrs), do: attrs
end
