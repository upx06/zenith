defmodule Zenith.Accounts do
  use Ash.Domain,
    otp_app: :zenith

  resources do
    resource Zenith.Accounts.Token
    resource Zenith.Accounts.User
  end
end
