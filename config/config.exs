import Config

config :rinha,
  port: System.get_env("PORT", "4000"),
  nodes: [:rinha1@localhost, :rinha2@localhost],
  initial_values: %{
    1 => {1, 100_000, 0},
    2 => {2, 80000, 0},
    3 => {3, 1_000_000, 0},
    4 => {4, 10_000_000, 0},
    5 => {5, 500_000, 0}
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
