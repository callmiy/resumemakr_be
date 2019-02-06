defmodule RMEmails.DefaultImplTest do
  use ExUnit.Case, async: true

  import Swoosh.TestAssertions

  alias RMEmails.DefaultImpl
  alias RMEmails.DefaultImpl.Composition

  test "send_welcome/1 sends welcome message to appropriate email" do
    email = "noreply@test.us"

    assert :ok = DefaultImpl.send_welcome(email)

    email
    |> Composition.welcome()
    |> assert_email_sent()
  end
end
