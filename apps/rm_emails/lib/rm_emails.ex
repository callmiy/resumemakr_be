defmodule RMEmails do
  @moduledoc ~S"""
    Used for sending emails to users
  """

  import Constantizer

  alias RMEmails.DefaultImpl

  @type email_address :: binary()

  @behaviour RMEmails.Impl

  @impl true
  @spec send_welcome(email_address) :: :ok
  def send_welcome(email_address) do
    impl().send_welcome(email_address)
  end

  defconstp impl do
    Application.get_env(:rm_emails, :impl, DefaultImpl)
  end
end
