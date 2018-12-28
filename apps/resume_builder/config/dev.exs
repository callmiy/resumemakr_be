# Since configuration is shared in umbrella projects, this file
# should only configure the :resume_builder application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

# Configure your database
config :resume_builder, ResumeBuilder.Repo,
  username: "postgres",
  password: "",
  database: "resume_builder_dev",
  hostname: "localhost",
  pool_size: 10
