defmodule FunctionServerBasedOnArweave.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FunctionServerBasedOnArweave.Repo,
      # Start the Telemetry supervisor
      FunctionServerBasedOnArweaveWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FunctionServerBasedOnArweave.PubSub},
      # Start the Endpoint (http/https)
      FunctionServerBasedOnArweaveWeb.Endpoint,
      # Start a worker by calling: FunctionServerBasedOnArweave.Worker.start_link(arg)
      # {FunctionServerBasedOnArweave.Worker, arg}
      {CodesOnChain.Syncer, [contract_addr: "0xb6fc950c4bc9d1e4652cbedab748e8cdcfe5655f"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FunctionServerBasedOnArweave.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FunctionServerBasedOnArweaveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
