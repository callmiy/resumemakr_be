defmodule RMEmails.DefaultImpl.Mailer do
  @moduledoc false
  use Swoosh.Mailer, otp_app: :rm_emails
end
