defmodule Data.Repo do
  use Ecto.Repo,
    otp_app: :data,
    adapter: Ecto.Adapters.Postgres

  if Mix.env() != :prod do
    def truncate_all do
      """
        TRUNCATE TABLE
          users
        RESTART IDENTITY
        CASCADE;
      """
      |> query!([])
    end
  end
end
