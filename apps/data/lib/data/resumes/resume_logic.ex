defmodule Data.Resumes.ResumeLogic do
  @moduledoc """
  Logic related to resume
  """

  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.Resumes.Resume
  alias Data.Resumes

  @title_with_time_pattern ~r/^(.+?)(?:_\d{10})+$/
  @resume_assoc_fields Resume.assoc_fields()

  @doc """
  Gets a single Resume.

  ## Examples

      iex> get_resume("abcde", "ef")
      %Resume{}

      iex> get_resume("abcde", "ef")
      ** nil

  """
  @spec get_resume(
          user_id :: String.t(),
          resume_id :: String.t()
        ) :: Resume.t() | nil
  def get_resume(user_id, resume_id) do
    from(
      r in Resume,
      where: r.user_id == ^user_id and r.id == ^resume_id
    )
    |> Repo.all()
    |> case do
      [resume] ->
        resume

      _ ->
        nil
    end
  end

  @spec get_resume_by(Map.t() | Keyword.t()) :: Resume.t()
  def get_resume_by(attrs) do
    attrs
    |> Enum.reduce(Resume, &get_resume_by_reducer_fn/2)
    |> Repo.all()
    |> case do
      [resume] ->
        resume

      _ ->
        nil
    end
  end

  defp get_resume_by_reducer_fn({k, <<_time::48, _random::80>> = v}, query) do
    case Ecto.ULID.load(v) do
      {:ok, string} ->
        get_resume_by_reducer_fn({k, string}, query)

      _ ->
        query
    end
  end

  defp get_resume_by_reducer_fn({:id, id}, query) do
    where(query, [r], r.id == ^id)
  end

  defp get_resume_by_reducer_fn({:user_id, user_id}, query) do
    where(query, [r], r.user_id == ^user_id)
  end

  defp get_resume_by_reducer_fn(_, query) do
    query
  end

  @doc """
  Returns the list of resumes for a user.

  ## Examples

      iex> list_resumes(12345)
      [%Resume{}, ...]

  """

  def list_resumes(user_id) do
    Resume
    |> where([r], r.user_id == ^user_id)
    |> Repo.all()
  end

  @spec list_resumes(
          user_id :: String.t(),
          pagination_args :: %{
            after: nil | integer(),
            before: nil | integer(),
            first: nil | integer(),
            last: nil | integer()
          }
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
  def list_resumes(user_id, pagination_args) do
    Resume
    |> where([r], r.user_id == ^user_id)
    |> order_by([r], desc: r.updated_at)
    |> Absinthe.Relay.Connection.from_query(&Repo.all/1, pagination_args)
  end

  @doc """
  Creates a Resume.

  ## Examples

      iex> create_resume_full(%{field: value})
      {:ok, %Resume{}}

      iex> create_resume_full(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_resume(attrs :: map) ::
          {:ok, Resume.t()} | {:error, Ecto.Changeset.t()}
  def create_resume(attrs) do
    %Resume{}
    |> Resume.changeset(attrs)
    |> Repo.insert()
    |> maybe_error_unique_title()
  end

  defp maybe_error_unique_title(
         {
           :error,
           %Ecto.Changeset{
             changes: %{title: title},
             errors: [title: {_, error}]
           } = changeset
         } = result
       ) do
    case Keyword.get(error, :constraint) do
      :unique ->
        changeset
        |> Ecto.Changeset.force_change(:title, unique_title(title))
        |> Map.merge(%{errors: [], valid?: true})
        |> Repo.insert()

      _ ->
        result
    end
  end

  defp maybe_error_unique_title(result), do: result

  defp unique_title(title) do
    title =
      case Regex.run(@title_with_time_pattern, title) do
        nil ->
          title

        [_, title] ->
          title
      end

    "#{title}_#{System.os_time(:second)}"
  end

  @doc """
  Updates a Resume.

  ## Examples

      iex> update_resume(Resume, %{field: new_value})
      {:ok, %Resume{}}

      iex> update_resume(Resume, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_resume(%Resume{} = resume, %{} = attrs) do
    resume = Repo.preload(resume, @resume_assoc_fields)

    resume
    |> Resume.changeset(augment_attrs(resume, attrs))
    |> Repo.update()
  end

  @doc ~S"""
    If the update attributes are missing fields from the original
    resume, them we copy the missing fields from the resume retrieved
    from the database into the update attributes.

    The reason for this is because we are using
    Ecto.Changeset.cast_assoc which will raise by default if there are
    missing associations
  """
  @spec augment_attrs(Resume.t(), map()) :: Map.t()
  def augment_attrs(%Resume{} = resume, %{} = attrs) do
    resume
    |> Map.from_struct()
    |> Enum.reduce(%{}, fn
      {k, _}, acc
      when k in [
             :__meta__,
             :inserted_at,
             :updated_at,
             :title,
             :id,
             :user_id
           ] ->
        update_if_key(k, attrs, acc)

      {k, v_db}, acc when k in @resume_assoc_fields ->
        sanitize_assoc(k, v_db, acc, attrs)

      {k, v}, acc when is_list(v) ->
        Map.put(acc, k, attrs[k] || [])

      {k, _v}, acc ->
        update_if_key(k, attrs, acc)
    end)
  end

  defp sanitize_assoc(key, v_db, acc, attrs) when v_db == nil or v_db == [] do
    update_if_key(key, attrs, acc)
  end

  defp sanitize_assoc(:personal_info, v_db, acc, attrs) do
    case Map.get(attrs, :personal_info, :ok) do
      :ok ->
        acc

      nil ->
        Map.put(
          acc,
          :personal_info,
          v_db |> Map.delete(:photo) |> mark_for_deletion()
        )

      v_user ->
        # we assume user is trying to update/delete
        Map.put(
          acc,
          :personal_info,
          v_user |> sanitize_photo() |> Map.put(:id, v_db.id)
        )
    end
  end

  defp sanitize_assoc(key, v_dbs, acc, attrs) do
    case Map.get(attrs, key, :ok) do
      :ok ->
        acc

      v_user when v_user == nil or v_user == [nil] ->
        Map.put(
          acc,
          key,
          Enum.map(v_dbs, &mark_for_deletion/1)
        )

      v_user ->
        {with_ids, no_ids} =
          Enum.reduce(v_user, {%{}, []}, fn assoc, {with_ids, no_ids} ->
            case Map.has_key?(assoc, :id) do
              true ->
                {Map.put(with_ids, to_string(assoc.id), assoc), no_ids}

              _ ->
                {with_ids, [assoc | no_ids]}
            end
          end)

        updates =
          Enum.reduce(v_dbs, [], fn assoc, acc ->
            id = to_string(assoc.id)

            case with_ids[id] do
              nil ->
                [mark_for_deletion(assoc) | acc]

              update_assoc ->
                [update_assoc | acc]
            end
          end)
          |> Enum.concat(no_ids)

        Map.put(acc, key, updates)
    end
  end

  defp mark_for_deletion(schema) do
    schema |> Map.from_struct() |> Map.put(:delete, true)
  end

  defp sanitize_photo(personal_info) do
    already_uploaded = Resumes.already_uploaded()

    case personal_info[:photo] || personal_info["photo"] do
      ^already_uploaded ->
        Map.drop(personal_info, [:photo, "photo"])

      %{file_name: _} ->
        Map.drop(personal_info, [:photo, "photo"])

      _ ->
        personal_info
    end
  end

  defp update_if_key(k, attrs, acc) do
    case Map.has_key?(attrs, k) do
      true ->
        Map.put(acc, k, attrs[k])

      _ ->
        acc
    end
  end

  @doc """
  Deletes a Resume.

  ## Examples

      iex> delete_resume(Resume)
      {:ok, %Resume{}}

      iex> delete_resume(Resume)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resume(%Resume{} = resume) do
    Repo.delete(resume)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking Resume changes.

  ## Examples

      iex> change_resume(Resume)
      %Ecto.Changeset{source: %Resume{}}

  """
  def change_resume(%Resume{} = resume) do
    Resume.changeset(resume, %{})
  end

  @doc """
  Clones a Resume.

  ## Examples

      iex> resume_resume(Resume)
      {:ok, %Resume{}}

      iex> resume_resume(Resume)
      {:error, %Ecto.Changeset{}}

  """
  def clone_resume(%Resume{} = resume, attrs \\ %{}) do
    resume = Repo.preload(resume, @resume_assoc_fields)

    attrs =
      resume
      |> clone_resume_attrs()
      |> Map.merge(attrs)
      |> Map.put(:title, clone_title(resume.title, attrs[:title]))

    changeset = Resume.changeset(%Resume{}, attrs)

    case (attrs.personal_info || %{}) |> Map.get(:photo_path) do
      nil ->
        changeset

      photo_path ->
        changeset.changes.personal_info
        |> update_in(&Ecto.Changeset.put_change(&1, :photo, photo_path))
    end
    |> Repo.insert()
  end

  defp clone_title(from_title, nil) do
    unique_title(from_title)
  end

  defp clone_title(from_title, from_title) do
    unique_title(from_title)
  end

  defp clone_title(_, to_title) do
    to_title
  end

  defp clone_resume_attrs(%_struct{} = v),
    do:
      Map.from_struct(v)
      |> Map.delete(:__meta__)
      |> clone_resume_attrs()

  defp clone_resume_attrs(%{} = data) do
    Enum.reduce(data, %{}, fn
      {:photo, %{file_name: _} = path}, acc ->
        Map.merge(acc, %{photo: nil, photo_path: path})

      {_k, %Ecto.Association.NotLoaded{}}, acc ->
        acc

      {k, _}, acc when k in [:updated_at, :inserted_at, :resume_id, :id] ->
        acc

      {k, v}, acc ->
        Map.put(acc, k, clone_resume_attrs(v))
    end)
    |> Enum.into(%{})
  end

  defp clone_resume_attrs(v) when is_list(v), do: Enum.map(v, &clone_resume_attrs/1)
  defp clone_resume_attrs(v), do: v
end
