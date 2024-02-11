import Config

config :rinha,
  port: System.get_env("PORT", "4000"),
  nodes: [:rinha@api01, :rinha@api02]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
