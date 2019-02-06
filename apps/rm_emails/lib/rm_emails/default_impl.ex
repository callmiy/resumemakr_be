defmodule RMEmails.DefaultImpl do
  @moduledoc false

  alias RMEmails.DefaultImpl.Mailer
  alias RMEmails.DefaultImpl.Composition

  @behaviour RMEmails.Impl

  @type email_address :: RMEmails.email_address()

  @impl true
  @spec send_welcome(email_address) :: :ok
  def send_welcome(email_address) do
    email_address |> Composition.welcome() |> Mailer.deliver()
    :ok
  end
end
