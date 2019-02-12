defmodule Data.ResolverUser do
  alias Data.Accounts
  alias Data.Accounts.User
  alias Data.Accounts.Credential
  alias Data.Resolver
  alias Data.Guardian

  def create(_root, params, _info) do
    with {:ok, user} <- Accounts.register(params),
         {:ok, jwt, _claim} <- Guardian.encode_and_sign(user) do
      {:ok, %{user: %User{user | jwt: jwt}}}
    else
      {:error, failed_operations, changeset} ->
        {
          :error,
          Resolver.transaction_errors_to_string(changeset, failed_operations)
        }

      error ->
        {:error, inspect(error)}
    end
  end

  def update(_, params, %{context: %{current_user: user}}) do
    with {:ok, created_user} <- Accounts.update_user(user, params),
         {:ok, new_jwt, _claim} <- Guardian.encode_and_sign(created_user) do
      {:ok, %{user: %User{created_user | jwt: new_jwt}}}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :error,
          changeset.errors
          |> Resolver.errors_to_map()
          |> Jason.encode!()
        }

      _ ->
        Resolver.unauthorized()
    end
  end

  def login(_root, params, _info) do
    with {:ok, %{user: user}} <- Accounts.authenticate(params),
         {:ok, jwt, _claim} <- Guardian.encode_and_sign(user) do
      {:ok, %{user: %User{user | jwt: jwt}}}
    end
  end

  def refresh(_root, %{jwt: jwt}, _info) do
    with {:ok, _claims} <- Guardian.decode_and_verify(jwt),
         {:ok, _old, {new_jwt, _claims}} = Guardian.refresh(jwt),
         {:ok, user, _claims} <- Guardian.resource_from_token(jwt) do
      {:ok, %User{user | jwt: new_jwt}}
    else
      {:error, %ArgumentError{}} ->
        {
          :error,
          Jason.encode!(%{
            error: "invalid_token"
          })
        }

      {:error, errs} ->
        {
          :error,
          Jason.encode!(%{
            error: errs
          })
        }
    end
  end

  def anfordern_passwort_zuruck_setzen(_root, %{email: email} = args, _) do
    with %Credential{
           user: user
         } = credential <- Accounts.get_credential_by(args),
         {:ok, jwt, _claim} <- Guardian.encode_and_sign(user),
         {:ok, result} <- Accounts.anfordern_passwort_zuruck_setzen(credential, jwt) do
      {:ok, result}
    else
      nil ->
        {:error, "Unknown user email: #{email}"}

      {:error, err} ->
        {:error, Jason.encode!(%{error: err})}
    end
  end

  def veranderung_passwort_zuruck_setzen(_source, params, _) do
    {token, aktualisieren_params} = Map.pop(params, :token)

    with {:ok, %{user: user}} <- Accounts.bekommt_anmelden_info_pzs(token, aktualisieren_params),
         {:ok, jwt, _claim} <- Guardian.encode_and_sign(user) do
      {:ok, %{user: %User{user | jwt: jwt}}}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {
          :error,
          changeset.errors
          |> Resolver.errors_to_map()
          |> Jason.encode!()
        }

      _ ->
        Resolver.unauthorized()
    end
  end

  def pzs_token_kontrollieren(_, %{token: token}, _) do
    case Accounts.pzs_token_nicht_ablaufen(token, true) do
      %{} ->
        {:ok, %{token: token}}

      _ ->
        Resolver.unauthorized()
    end
  end
end
