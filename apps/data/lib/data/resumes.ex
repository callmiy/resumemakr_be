defmodule Data.Resumes do
  @moduledoc """
  The Resume context.
  """

  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.Resumes.PersonalInfo
  alias Data.Resumes.Resume
  alias Data.Resumes.Experience
  alias Data.Resumes.Education
  alias Ecto.Changeset

  @already_uploaded "___ALREADY_UPLOADED___"
  @resume_assoc_fields Resume.assoc_fields()
  @title_with_time_pattern ~r/^(.+?)(?:_\d{10})+$/

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

  @spec list_resumes(any(), %{
          after: nil | integer(),
          before: nil | integer(),
          first: nil | integer(),
          last: nil | integer()
        }) ::
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
  Gets a single Resume.

  Raises `Ecto.NoResultsError` if the Resume does not exist.

  ## Examples

      iex> get_resume!(123)
      %Resume{}

      iex> get_resume!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resume(id), do: Repo.get(Resume, id)

  def get_resume_by(attrs) do
    Repo.get_by(Resume, attrs)
  end

  @doc """
  Creates a Resume.

  ## Examples

      iex> create_resume_full(%{field: value})
      {:ok, %Resume{}}

      iex> create_resume_full(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_resume(attrs) do
    %Resume{}
    |> Resume.changeset(attrs)
    |> Repo.insert()
    |> maybe_error_unique_title()
  end

  defp maybe_error_unique_title(
         {:error,
          %Ecto.Changeset{changes: %{title: title}, errors: [title: {_, error}]} = changeset} =
           result
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
    case personal_info[:photo] || personal_info["photo"] do
      @already_uploaded ->
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

  @doc """
  Returns the list of personal_info.

  ## Examples

      iex> list_personal_info()
      [%PersonalInfo{}, ...]

  """
  def list_personal_info do
    Repo.all(PersonalInfo)
  end

  @doc """
  Gets a single personal_info.

  Raises `Ecto.NoResultsError` if the Personal info does not exist.

  ## Examples

      iex> get_personal_info!(123)
      %PersonalInfo{}

      iex> get_personal_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_personal_info!(id), do: Repo.get!(PersonalInfo, id)

  @doc """
  Updates a personal_info.

  ## Examples

      iex> update_personal_info(personal_info, %{field: new_value})
      {:ok, %PersonalInfo{}}

      iex> update_personal_info(personal_info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_personal_info(%PersonalInfo{} = personal_info, attrs) do
    personal_info
    |> PersonalInfo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PersonalInfo.

  ## Examples

      iex> delete_personal_info(personal_info)
      {:ok, %PersonalInfo{}}

      iex> delete_personal_info(personal_info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_personal_info(%PersonalInfo{} = personal_info) do
    Repo.delete(personal_info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking personal_info changes.

  ## Examples

      iex> change_personal_info(personal_info)
      %Ecto.Changeset{source: %PersonalInfo{}}

  """
  def change_personal_info(%PersonalInfo{} = personal_info) do
    PersonalInfo.changeset(personal_info, %{})
  end

  @doc """
  Returns the list of experiences.

  ## Examples

      iex> list_experiences()
      [%Experience{}, ...]

  """
  def list_experiences do
    Repo.all(Experience)
  end

  @doc """
  Gets a single experience.

  Raises `Ecto.NoResultsError` if the Experience does not exist.

  ## Examples

      iex> get_experience!(123)
      %Experience{}

      iex> get_experience!(456)
      ** (Ecto.NoResultsError)

  """
  def get_experience!(id), do: Repo.get!(Experience, id)

  @doc """
  Updates a experience.

  ## Examples

      iex> update_experience(experience, %{field: new_value})
      {:ok, %Experience{}}

      iex> update_experience(experience, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_experience(%Experience{} = experience, attrs) do
    experience
    |> Experience.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Experience.

  ## Examples

      iex> delete_experience(experience)
      {:ok, %Experience{}}

      iex> delete_experience(experience)
      {:error, %Ecto.Changeset{}}

  """
  def delete_experience(%Experience{} = experience) do
    Repo.delete(experience)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking experience changes.

  ## Examples

      iex> change_experience(experience)
      %Ecto.Changeset{source: %Experience{}}

  """
  def change_experience(%Experience{} = experience) do
    Experience.changeset(experience, %{})
  end

  ################################# EDUCATION #################################

  @doc """
  Returns the list of education.

  ## Examples

      iex> list_education()
      [%Education{}, ...]

  """
  def list_education do
    Repo.all(Education)
  end

  @doc """
  Gets a single education.

  Raises `Ecto.NoResultsError` if the Education does not exist.

  ## Examples

      iex> get_education!(123)
      %Education{}

      iex> get_education!(456)
      ** (Ecto.NoResultsError)

  """
  def get_education!(id), do: Repo.get!(Education, id)

  @doc """
  Creates a education.

  ## Examples

      iex> create_education(%{field: value})
      {:ok, %Education{}}

      iex> create_education(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_education(attrs \\ %{}) do
    %Education{}
    |> Education.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a education.

  ## Examples

      iex> update_education(education, %{field: new_value})
      {:ok, %Education{}}

      iex> update_education(education, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_education(%Education{} = education, attrs) do
    education
    |> Education.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Education.

  ## Examples

      iex> delete_education(education)
      {:ok, %Education{}}

      iex> delete_education(education)
      {:error, %Ecto.Changeset{}}

  """
  def delete_education(%Education{} = education) do
    Repo.delete(education)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking education changes.

  ## Examples

      iex> change_education(education)
      %Ecto.Changeset{source: %Education{}}

  """
  def change_education(%Education{} = education) do
    Education.changeset(education, %{})
  end

  alias Data.Resumes.Skill

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    Repo.all(Skill)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id), do: Repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    Repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{source: %Skill{}}

  """
  def change_skill(%Skill{} = skill) do
    Skill.changeset(skill, %{})
  end

  @spec maybe_mark_for_deletion(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def maybe_mark_for_deletion(%Changeset{} = changeset) do
    if Changeset.get_change(changeset, :delete) do
      %Changeset{changeset | action: :delete, valid?: true, errors: []}
    else
      changeset
    end
  end

  def already_uploaded, do: @already_uploaded
end
