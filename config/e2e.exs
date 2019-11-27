use Mix.Config

import_config "dev.exs"

config :data, sql_sandbox: true

config :logger, :console,
  format: "###### $time $metadata[$level] $message\n",
  metadata: [:request_id]

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 10

config :data, Data.Repo,
  username: "postgres",
  password: "postgres",
  database: "resumemakr_e2e",
  hostname: "localhost",
  pool_size: 20

server_port = System.get_env("RESUME_MAKR_PHOENIX_PORT") || 4017
front_end_port = System.get_env("RESUME_MAKR_FRONTEND_PORT") || "3022"

config :web, front_end_url: "http://localhost:" <> front_end_port

config :web, Web.Endpoint,
  http: [port: server_port],
  server: true

config :resumemakr,
  is_e2e: true
