defmodule Emails.DefaultImpl do
  @moduledoc false

  alias Emails.DefaultImpl.Mailer
  alias Emails.DefaultImpl.Composition

  @behaviour Emails.Impl

  @type email_address :: Emails.email_address()

  @impl true
  @spec send_welcome(email_address) :: :ok
  def send_welcome(email_address) do
    email_address |> Composition.welcome() |> Mailer.deliver()
    :ok
  end

  @impl true
  @spec send_password_recovery(email_address, token :: binary()) :: :ok
  def send_password_recovery(email_address, token) do
    email_address
    |> Composition.password_recovery(token)
    |> Mailer.deliver()

    :ok
  end
end
