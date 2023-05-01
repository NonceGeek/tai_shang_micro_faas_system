defmodule TaiShangMicroFaasSystem.Repo do
  use Ecto.Repo,
    otp_app: :tai_shang_micro_faas_system,
    adapter: Ecto.Adapters.Postgres

  use Paginator
end
