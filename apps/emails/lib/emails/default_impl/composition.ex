defmodule Emails.DefaultImpl.Composition do
  @moduledoc false
  import Swoosh.Email

  @from_email "noreply@resumemakr.com"

  def welcome(email) do
    new()
    |> to(email)
    |> from(@from_email)
    |> subject("Welcome to ResumeMakr!")
    |> html_body("<h1>Thanks for signing up for ResumeMakr, #{email}!</h1>")
  end

  def password_recovery(email, token) do
    msg =
      Phoenix.View.render_to_string(
        Emails,
        "recovery.html",
        token: token
      )

    new()
    |> to(email)
    |> from(@from_email)
    |> subject("Reset your password")
    |> html_body(msg)
  end
end
