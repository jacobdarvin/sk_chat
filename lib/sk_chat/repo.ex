defmodule SkChat.Repo do
  use Ecto.Repo,
    otp_app: :sk_chat,
    adapter: Ecto.Adapters.Postgres
end
