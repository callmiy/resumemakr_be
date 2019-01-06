# Since configuration is shared in umbrella projects, this file
# should only configure the :data application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :data, Data.Repo,
  username: "postgres",
  password: "postgres",
  database: "data_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
