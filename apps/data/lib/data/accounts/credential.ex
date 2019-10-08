defmodule Data.Accounts.Credential do
  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset
  alias Data.Accounts.User

  @cast_attrs [
    :source,
    :token,
    :user_id,
    :password,
    :recovery_token,
    :recovery_token_expires
  ]

  schema "credentials" do
    field(:source, :string)
    # the encrypted password or token from auth source e.g. google
    field(:token, :string)

    # in case user chooses to use password as source
    field(:password, :string, virtual: true)
    field(:recovery_token, :string)
    field(:recovery_token_expires, :utc_datetime)
    belongs_to(:user, User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(%__MODULE__{} = schema, attrs \\ %{}) do
    schema
    |> cast(attrs, @cast_attrs)
    |> validate()
  end

  def validate(%Changeset{data: %User{}, changes: changes}) do
    __MODULE__.__struct__()
    |> cast(changes, @cast_attrs)
  end

  def validate(%Changeset{} = changes) do
    changes
    |> validate_required([:source])
    |> unique_constraint(:source, name: :credential_user_id_source_index)
    |> hash_password()
  end

  defp hash_password(
         %Changeset{
           valid?: true,
           changes: %{
             source: "password",
             password: password
           }
         } = changes
       ) do
    put_change(changes, :token, Pbkdf2.hash_pwd_salt(password))
  end

  defp hash_password(changes), do: changes
end
