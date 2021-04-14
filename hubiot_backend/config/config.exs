# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :hubiot,
  ecto_repos: [Hubiot.Repo]

# Configures the endpoint
config :hubiot, HubiotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "09lNl/y3JsTmGhD2UbP13VuGeePv3dwk/pFhnncWQAKo8ocKqfXlb7R6nsnFUO9u",
  render_errors: [view: HubiotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Hubiot.PubSub,
  live_view: [signing_salt: "hEIh1U17"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
