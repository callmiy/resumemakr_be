defmodule RMEmails.DefaultImpl.Composition do
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
end
