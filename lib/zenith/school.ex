
defmodule Zenith.School do
  use Ash.Domain,
    otp_app: :zenith,
    extensions: [AshGraphql.Domain]

  graphql do
    root_level_errors? true
    authorize? true
  end

  resources do
  end
end
