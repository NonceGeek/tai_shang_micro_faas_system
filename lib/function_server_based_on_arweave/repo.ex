defmodule FunctionServerBasedOnArweave.Repo do
  use Ecto.Repo,
    otp_app: :function_server_based_on_arweave,
    adapter: Ecto.Adapters.Postgres
end
