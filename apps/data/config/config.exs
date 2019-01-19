# Since configuration is shared in umbrella projects, this file
# should only configure the :data application itself
# and only for organization purposes. All other config goes to
# the umbrella root.
use Mix.Config

config :data,
  ecto_repos: [Data.Repo]

config :data, Data.Guardian,
  issuer: "resume_makr",
  secret_key: "zsnX+gxvw+s3pqc0kXSjMFKgQRIwe14WPF4nQ0M9aDTkQJ+gfAwb36fdhQAmPCh9"

config :arc,
  storage: Arc.Storage.Local

config :arc,
  storage_dir: "uploads"

config :goth,
  json: """
    {
      "type": "service_account",
      "project_id": "",
      "private_key_id": "3f1d7f704b624e646175f75292d6bc92424d4e96",
      "private_key": "-----BEGIN PRIVATE KEY-----\nM==\n-----END PRIVATE KEY-----\n",
      "client_email": "a@ab.com",
      "client_id": "1",
      "auth_uri": "https://ab.com/auth",
      "token_uri": "https://ab.com/token",
      "auth_provider_x509_cert_url": "https://www.ab.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.ab.com"
    }
  """

import_config "#{Mix.env()}.exs"
