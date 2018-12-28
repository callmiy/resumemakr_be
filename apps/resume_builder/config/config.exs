# Since configuration is shared in umbrella projects, this file
# should only configure the :resume_builder application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :resume_builder,
  ecto_repos: [ResumeBuilder.Repo]

import_config "#{Mix.env()}.exs"
