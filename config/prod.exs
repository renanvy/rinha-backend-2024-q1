import Config

config :rinha,
  nodes: [:api01@localhost, :api02@localhost]

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
