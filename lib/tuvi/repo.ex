defmodule Tuvi.Repo do
  use Ecto.Repo,
    otp_app: :tuvi,
    adapter: Ecto.Adapters.Postgres
end
