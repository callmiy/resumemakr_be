defmodule Emails do
  use Phoenix.View,
    root: "lib/emails/templates",
    namespace: Emails

  @moduledoc ~S"""
    Used for sending emails to users
  """

  alias Emails.DefaultImpl

  @app Application.get_env(:emails, :impl, DefaultImpl)
  @type email_address :: binary()

  @behaviour Emails.Impl

  @impl true
  @spec send_welcome(email_address) :: :ok
  def send_welcome(email_address) do
    @app.send_welcome(email_address)
  end

  @impl true
  @spec send_password_recovery(email_address, token :: binary()) :: :ok
  def send_password_recovery(email_address, token) do
    @app.send_password_recovery(email_address, token)
    :ok
  end
end
