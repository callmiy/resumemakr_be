# Since configuration is shared in umbrella projects, this file
# should only configure the :data application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :data,
  ecto_repos: [Data.Repo]

import_config "#{Mix.env()}.exs"
