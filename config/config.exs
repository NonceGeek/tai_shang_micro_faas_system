# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :function_server_based_on_arweave,
  ecto_repos: [FunctionServerBasedOnArweave.Repo],
  arweave_endpoint: "https://arweave.net",
  arweave_explorer: "https://viewblock.io/arweave/tx",
  # contract_addr: "0xD1e91A4Bf55111dD3725E46A64CDbE7a2cC97D8a",
  # contract_endpoint: "https://rpc.api.moonbase.moonbeam.network",
  # eth_explorer: "https://moonbase.moonscan.io",
  contract_addr: "0xE25827DedD435aD3C4B90bD5BaBEf3CF462884Be",
  contract_endpoint: "https://dev.kardiachain.io",
  eth_explorer: "https://explorer-dev.kardiachain.io",
  gallery: "https://moonbeam.nftscan.com/search",
  my_infura_id: "",
  # ipfs_node: "https://ipfs.io"
  write_ipfs_node: "https://ipfs.infura.io",
  read_ipfs_node: System.get_env("WRITE_IPFS_NODE"),
  ipfs_project_id: "2DywRf468SVsu4rA8PYjQ5bwO0j",
  ipfs_api_key_secret: System.get_env("IPFS_API_KEY_SECRET"),
  github_token: System.get_env("GITHUB_TOKEN")

# Configures the endpoint
config :function_server_based_on_arweave, FunctionServerBasedOnArweaveWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: FunctionServerBasedOnArweaveWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: FunctionServerBasedOnArweave.PubSub,
  live_view: [signing_salt: "mbnVB7Pw"]

# Authentication
config :function_server_based_on_arweave, :pow,
  user: FunctionServerBasedOnArweave.Users.User,
  repo: FunctionServerBasedOnArweave.Repo,
  web_module: FunctionServerBasedOnArweaveWeb

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :function_server_based_on_arweave, FunctionServerBasedOnArweave.Mailer,
  adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ethereumex,
  http_options: [pool_timeout: 5000, receive_timeout: 15_000],
  http_headers: [
    {"Content-Type", "application/json"}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
