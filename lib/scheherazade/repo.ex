defmodule Scheherazade.Repo do
  use Ecto.Repo,
  otp_app: :scheherazade,
  adapter: Ecto.Adapters.Postgres
end
