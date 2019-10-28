defmodule Data.Resumes.EducationLgic do
  import Ecto.Query

  alias Data.Repo
  alias Data.Resumes.Education

  @doc """
  Gets a single education.

  Raises `Ecto.NoResultsError` if the Education does not exist.

  ## Examples

      iex> get_education(123)
      %Education{}

      iex> get_education(456)
      ** (Ecto.NoResultsError)

  """
  def get_education(attrs) do
    from(
      e in Education,
      join: r in assoc(e, :resume),
      where: e.id == ^attrs.id and r.user_id == ^attrs.user_id
    )
    |> Repo.all()
    |> case do
      [education] ->
        education

      _ ->
        nil
    end
  end

  @doc """
  Creates a education.

  ## Examples

      iex> create_education(%{field: value})
      {:ok, %Education{}}

      iex> create_education(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_education(attrs) do
    %Education{}
    |> Education.changeset(attrs)
    |> Repo.insert()
  end
end
