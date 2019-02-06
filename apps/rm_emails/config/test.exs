use Mix.Config

config :rm_emails, RMEmails.DefaultImpl.Mailer, adapter: Swoosh.Adapters.Test

config :constantizer, resolve_at_compile_time: false
