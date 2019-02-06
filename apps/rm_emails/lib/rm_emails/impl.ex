defmodule RMEmails.Impl do
  @moduledoc false

  @callback send_welcome(RMEmails.email_address()) :: :ok
end
