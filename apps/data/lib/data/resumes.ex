defmodule Data.Resumes do
  @moduledoc """
  The Resume context.
  """

  import Ecto.Query, warn: false
  alias Data.Repo
  alias Data.Resumes.PersonalInfo
  alias Data.Resumes.Experience
  alias Data.Resumes.Education
  alias Ecto.Changeset
  alias Data.Resumes.ResumeLogic
  alias Data.Resumes.SpokenLanguageLogic

  @already_uploaded "___ALREADY_UPLOADED___"

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

  defdelegate get_resume(user_id, resume_id), to: ResumeLogic
  defdelegate get_resume_by(attrs), to: ResumeLogic
  defdelegate list_resumes(user_id), to: ResumeLogic
  defdelegate list_resumes(user_id, pagination_args), to: ResumeLogic
  defdelegate create_resume(attrs), to: ResumeLogic
  defdelegate update_resume(resume, attrs), to: ResumeLogic
  defdelegate delete_resume(resume), to: ResumeLogic
  defdelegate clone_resume(resume, attrs), to: ResumeLogic
  defdelegate create_spoken_language(attrs), to: SpokenLanguageLogic
end
