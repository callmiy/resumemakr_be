defmodule ResumeBuilder.Repo do
  use Ecto.Repo,
    otp_app: :resume_builder,
    adapter: Ecto.Adapters.Postgres
end
