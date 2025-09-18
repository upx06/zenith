defmodule Zenith.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Zenith.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:zenith, :token_signing_secret)
  end
end
