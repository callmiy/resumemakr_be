# Since configuration is shared in umbrella projects, this file
# should only configure the :web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :web,
  ecto_repos: [Data.Repo],
  generators: [context_app: :data]

config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "FcgHpcgHf7DWlPXNO/RWQnpfGOqmHUaHIMjNYUTthcLdq4TOIfquw7r6AzVoAY2W",
  render_errors: [view: Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

config :phoenix, :json_library, Jason

config :web, Web.Guardian,
  issuer: "resume_builder",
  secret_key: "zsnX+gxvw+s3pqc0kXSjMFKgQRIwe14WPF4nQ0M9aDTkQJ+gfAwb36fdhQAmPCh9"

config :web, Web.Plug.Guardian.Pipeline,
  module: Web.Guardian,
  error_handler: Web.Plug.Guardian.Pipeline

import_config "#{Mix.env()}.exs"
