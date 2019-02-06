defmodule Data.Repo.Migrations.CredentialPasswordRecovery do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :recovery_token, :text
      add :recovery_token_expires, :utc_datetime
    end
  end
end
