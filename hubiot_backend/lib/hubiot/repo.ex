defmodule Hubiot.Repo do
  use Ecto.Repo,
    otp_app: :hubiot,
    adapter: Ecto.Adapters.Postgres
end
