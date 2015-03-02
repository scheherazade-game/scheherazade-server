use Mix.Config

config :scheherazade, Scheherazade.Endpoint,
  http: [port: System.get_env("PORT") || 4001]

config :comeonin,
  pbkdf2_rounds: 1_000

# Print only warnings and errors during test
config :logger, level: :warn
