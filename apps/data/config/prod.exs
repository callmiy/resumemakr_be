use Mix.Config

config :data, Data.Guardian,
  issuer: "resume_builder",
  secret_key: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :data, Data.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
