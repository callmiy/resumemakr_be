defmodule Data.Accounts do
  require Logger
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Accounts.Registration
  alias Data.Accounts.Credential
  alias Data.Accounts.User

  @password_reset_token_expires_in_hours 24

  @authenticate_user_exception_header "\n\nException while getting experience with:"
  @stacktrace "\n\n---------------STACKTRACE---------\n\n"

  # ACCOUNTS

  def register(%{} = params) do
    Ecto.Multi.new()
    |> Registration.create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, credential: credential}} ->
        user =
          Map.put(user, :credential, %{
            credential
            | token: nil,
              password: nil
          })

        {:ok, user}

      {:error, failed_operations, changeset, _successes} ->
        {:error, failed_operations, changeset}
    end
  end

  def authenticate(%{email: email, password: password} = _params) do
    Credential
    |> join(:inner, [c], assoc(c, :user))
    |> where([c, u], u.email == ^email)
    |> preload([c, u], user: u)
    |> Repo.one()
    |> case do
      nil ->
        {:error, "Invalid email/password"}

      %Credential{} = cred ->
        if Pbkdf2.verify_pass(password, cred.token) do
          {:ok, cred}
        else
          {:error, "Invalid email/password"}
        end
    end
  rescue
    error ->
      Logger.error(fn ->
        [
          @authenticate_user_exception_header,
          @stacktrace,
          :error
          |> Exception.format(error, __STACKTRACE__)
          |> Data.prettify_with_new_line()
        ]
      end)

      {:error, "Invalid email/password"}
  end

  #################################### CREDENTIAL ##############################

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credential()
      [%Credential{}, ...]

  """
  def list_credential do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential(123)
      %Credential{}

      iex> get_credential(456)
      ** nil

  """

  def get_credential(id), do: Repo.get(Credential, id)

  def get_credential_by(%{email: email}) do
    Credential
    |> join(:inner, [c], u in assoc(c, :user))
    |> where([c, u], u.email == ^email)
    |> preload([c, u], user: u)
    |> Repo.one()
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential, %{})
      %Ecto.Changeset{source: %Credential{}}

  """
  def change_credential(%Credential{} = credential, attrs \\ %{}) do
    Credential.changeset(credential, attrs)
  end

  @doc """
  Aktualisiert ein anmelden info

  ## Beispiele
      iex> bekommt_anmelden_info_pzs(nil, %{field: new_value})
      nil

      iex> bekommt_anmelden_info_pzs(token, %{password: x, confirm_password: x})
      {:ok, %Credential{}}

      iex> bekommt_anmelden_info_pzs(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def password_reset_token_not_expired(token, exec \\ false) do
    query =
      where(
        Credential,
        [c],
        c.recovery_token == ^token and c.recovery_token_expires >= ^DateTime.utc_now()
      )

    if exec, do: Repo.one(query), else: query
  end

  def bekommt_anmelden_info_pzs(nil, _), do: nil

  def bekommt_anmelden_info_pzs(token, params) do
    case token
         |> password_reset_token_not_expired()
         |> join(:inner, [c], u in assoc(c, :user))
         |> preload([c, u], user: u)
         |> Repo.one() do
      nil ->
        nil

      login_info ->
        case hash_password(params) do
          nil ->
            nil

          hash ->
            update_credential(login_info, %{
              recovery_token: nil,
              recovery_token_expires: nil,
              token: hash
            })
        end
    end
  end

  defp hash_password(%{password: password, password_confirmation: password}) do
    Pbkdf2.hash_pwd_salt(password)
  end

  defp hash_password(_), do: nil

  ################################## USERS ##################################

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_user()
      [%User{}, ...]

  """
  def list_user do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get(123)
      %User{}

      iex> get(456)
      ** nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_user_by(attrs), do: Repo.get_by(User, attrs)

  def get_password_token(%Credential{} = credential, jwt) do
    with {:ok, %{user: %{email: email}}} <-
           update_credential(credential, %{
             recovery_token: jwt,
             recovery_token_expires:
               Timex.now() |> Timex.shift(hours: @password_reset_token_expires_in_hours)
           }),
         :ok <- Emails.send_password_recovery(email, jwt) do
      {:ok, %{email: email}}
    end
  end

  def get_password_reset_token_expiry_in_hours, do: @password_reset_token_expires_in_hours
end
