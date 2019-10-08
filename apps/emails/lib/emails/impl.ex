defmodule Emails.Impl do
  @moduledoc false

  @callback send_welcome(Emails.email_address()) :: :ok
  @callback send_password_recovery(
              Emails.email_address(),
              token :: binary()
            ) :: :ok
end
