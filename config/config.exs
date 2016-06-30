# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :pest_server, PestServer.Endpoint,

  http: [dispatch: [
          {:_, [
                {"/ws", PestServer.WebSocket.Handler, []},
                {:_, Plug.Adapters.Cowboy.Handler, {PestServer.Endpoint, []}}
                ]}]],
  https: [dispatch: [
          {:_, [
                {"/ws", PestServer.WebSocket.Handler, []},
                {:_, Plug.Adapters.Cowboy.Handler, {PestServer.Endpoint, []}}
                ]}]],
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "N/05cpUX7clGHgC/MA2aVPa34AMZEUTZCKGKPHn7CaGN/TJ6WKgwOZfQmsmkkyET",
  render_errors: [accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :kafka_ex,
  # a list of brokers to connect to in {"HOST", port} format
  brokers: [
    {"localhost", 9092},
    {"localhost", 9093},
    {"localhost", 9094},
  ],
  # the default consumer group for worker processes, must be a binary (string)
  #    NOTE if you are on Kafka < 0.8.2 or if you want to disable the use of
  #    consumer groups, set this to :no_consumer_group (this is the
  #    only exception to the requirement that this value be a binary)
  consumer_group: "kafka_ex",
  # Set this value to true if you do not want the default
  # `KafkaEx.Server` worker to start during application start-up -
  # i.e., if you want to start your own set of named workers
  disable_default_worker: false,
  # Timeout value, in msec, for synchronous operations (e.g., network calls)
  sync_timeout: 3000,
  # Supervision max_restarts - the maximum amount of restarts allowed in a time frame
  max_restarts: 10,
  # Supervision max_seconds -  the time frame in which :max_restarts applies
  max_seconds: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
