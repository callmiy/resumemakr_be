use Mix.Config

app_port = System.get_env("RESUME_BUILDER_PHOENIX_TEST_PORT") || 4026

config :web, Web.Endpoint,
  http: [port: app_port],
  server: true

config :data, Data.Repo,
  username: "postgres",
  password: "postgres",
  database: "resume_builder_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  timeout: 60_000
