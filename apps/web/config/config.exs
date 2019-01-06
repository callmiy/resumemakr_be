# Since configuration is shared in umbrella projects, this file
# should only configure the :web application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# General application configuration
config :web,
  ecto_repos: [Data.Repo],
  generators: [context_app: :data]

# Configures the endpoint
config :web, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "budqoOVXUpYLGI54gqJR5x0l/RNrkUvLXq5N6YYm+71Lqws3WvBuGw08IXUFepTn",
  render_errors: [view: Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Web.PubSub, adapter: Phoenix.PubSub.PG2]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
