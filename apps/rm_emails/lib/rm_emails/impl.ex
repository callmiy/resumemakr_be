defmodule RMEmails.Impl do
  @moduledoc false

  @callback send_welcome(RMEmails.email_address()) :: :ok
  @callback send_password_recovery(
              RMEmails.email_address(),
              token :: binary()
            ) :: :ok
end
