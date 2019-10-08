# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

config :pbkdf2_elixir, :rounds, 1

# Configure Mix tasks and generators
config :data,
  ecto_repos: [Data.Repo]

config :web,
  ecto_repos: [Data.Repo],
  generators: [context_app: :data]

# Configures the endpoint
config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iRHXBhBVYfypgsBljwSPa1AMFn+M2be+XOZR9OgVsamKMv5KTYRRlYV1WgvzcJDS",
  render_errors: [view: Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

front_end_port = System.get_env("RESUME_MAKR_FRONT_END_PORT") || "4024"
config :web, front_end_url: "http://localhost:" <> front_end_port

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :emails, Emails.DefaultImpl.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay:
    System.get_env("RESUME_MAKR_SMTP_RELAY")
    |> Kernel.||("smtp.ethereal.email"),
  username:
    System.get_env("RESUME_MAKR_SMTP_USER")
    |> Kernel.||("loyal.farrell47@ethereal.email"),
  password:
    System.get_env("RESUME_MAKR_SMTP_PASS")
    |> Kernel.||("BxXEwfa5B7zfDHY941"),
  tls: :always,
  auth: :always,
  port:
    System.get_env("RESUME_MAKR_SMTP_PORT")
    |> Kernel.||("587")
    |> String.to_integer()

config :data, Data.Guardian,
  issuer: "resumemakr",
  secret_key: "DfAHXB4gq6YbApF5c5NgBP0kKpaaobjhFodpDzmceiaXfcPMZKDN1sBCTDHQ2RBy"

config :arc,
  storage: Arc.Storage.Local

config :arc,
  storage_dir: "uploads"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
