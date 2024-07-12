defmodule SecretQuest.Repo do
  use Ecto.Repo,
    otp_app: :secret_quest,
    adapter: Ecto.Adapters.Postgres
end
