import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.

config :chess, Chess.Repo,
  username: "postgres",
  password: "mysecretpassword",
  database: "chess_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "192.168.64.2",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chess, ChessWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7c/nNP1v0ttE0OBS57pvwSw/1BQAJYas1ya5Kw6qU/XSPz4lHMvkBZVsUI0s7Z5u",
  server: false

# In test we don't send emails.
config :chess, Chess.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
