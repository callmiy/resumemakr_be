# Since configuration is shared in umbrella projects, this file
# should only configure the :data application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :data,
  ecto_repos: [Data.Repo]

config :data, Data.Guardian,
  issuer: "resume_builder",
  secret_key: "zsnX+gxvw+s3pqc0kXSjMFKgQRIwe14WPF4nQ0M9aDTkQJ+gfAwb36fdhQAmPCh9"

import_config "#{Mix.env()}.exs"
