defmodule TaiShangMicroFaasSystemWeb.AuthHelpers do
  import Phoenix.LiveView

  alias Pow.Store.CredentialsCache
  alias Pow.Store.Backend.EtsCache
  alias TaiShangMicroFaasSystem.Users.User

  def get_user(socket, session, config \\ [otp_app: :tai_shang_micro_faas_system])

  def get_user(socket, %{"tai_shang_micro_faas_system_auth" => signed_token}, config) do
    conn = struct!(Plug.Conn, secret_key_base: socket.endpoint.config(:secret_key_base))
    salt = Atom.to_string(Pow.Plug.Session)

    with {:ok, token} <- Pow.Plug.verify_token(conn, salt, signed_token, config),
         {user, _metadata} <- CredentialsCache.get([backend: EtsCache], token) do
      user
    else
      _ -> nil
    end
  end

  def get_user(_, _, _), do: nil

  def login_as_buidler(conn, addr) do
    user = get_buidler_account(addr)
    |> User.get_by_email

    Pow.Plug.create(conn, user)
  end

  def auth_as_buidler(socket, addr) do
    email = get_buidler_account(addr)

    user = User.get_by_email(email)

    auth_as_buidler(socket, email, user)
  end

  def auth_as_buidler(socket, email, nil) do
    pwd = random(16)

    {:ok, user} = User.create_admin(%{
      "email" => email,
      "password" => pwd,
      "password_confirmation" => pwd,
      "password_hash" => pwd |> Pow.Ecto.Schema.Password.pbkdf2_hash()
    })

    auth_as_buidler(socket, email, user)
  end

  def auth_as_buidler(socket, _email, user) do
    assign(socket, current_user: user)
  end

  def random(bytes_count) do
    bytes_count
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end

  defp get_buidler_account(addr) do
    "#{addr}@faas.com"
  end
end
