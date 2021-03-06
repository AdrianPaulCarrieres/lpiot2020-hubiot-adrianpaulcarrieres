defmodule Capteur.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Capteur.Worker.start_link(arg)
      # {Capteur.Worker, arg}
      # {Capteur.Server, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Capteur.Supervisor]
    Supervisor.start_link(children, opts)

    Capteur.Server.start_link("salle_1")
    Capteur.Server.start_link("salle_2")
  end
end
