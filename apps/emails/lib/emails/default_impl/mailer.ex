defmodule Emails.DefaultImpl.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :emails
end
