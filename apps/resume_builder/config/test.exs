# Since configuration is shared in umbrella projects, this file
# should only configure the :resume_builder application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :resume_builder, ResumeBuilder.Repo,
  username: "postgres",
  password: "postgres",
  database: "resume_builder_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
