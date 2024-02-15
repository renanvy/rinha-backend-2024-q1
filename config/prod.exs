import Config

config :rinha,
  nodes: [:rinha@api01, :rinha2@api02]

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
