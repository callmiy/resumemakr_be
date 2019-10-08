use Mix.Config

# Configure your database
config :data, Data.Repo,
  username: "postgres",
  password: "postgres",
  database: "resumemakr_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :web, Web.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :emails, Emails.DefaultImpl.Mailer, adapter: Swoosh.Adapters.Test

config :mix_test_watch,
  clear: true
