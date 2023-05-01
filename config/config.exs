# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tai_shang_micro_faas_system,
  ecto_repos: [TaiShangMicroFaasSystem.Repo],
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
  github_token: System.get_env("GITHUB_TOKEN"),
  did_mainnet: "0x61b96051f553d767d7e6dfcc04b04c28d793c8af3d07d3a43b4e2f8f4ca04c9f",
  did_testnet: "0xc71124a51e0d63cfc6eb04e690c39a4ea36774ed4df77c00f7cbcbc9d0505b2c"

config :cors_plug,
  max_age: 2592000,
  methods: ["GET", "POST"]
# Configures the endpoint
config :tai_shang_micro_faas_system, TaiShangMicroFaasSystemWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: TaiShangMicroFaasSystemWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: TaiShangMicroFaasSystem.PubSub,
  live_view: [signing_salt: "mbnVB7Pw"]

# Authentication
config :tai_shang_micro_faas_system, :pow,
  user: TaiShangMicroFaasSystem.Users.User,
  repo: TaiShangMicroFaasSystem.Repo,
  web_module: TaiShangMicroFaasSystemWeb

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tai_shang_micro_faas_system, TaiShangMicroFaasSystem.Mailer,
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
