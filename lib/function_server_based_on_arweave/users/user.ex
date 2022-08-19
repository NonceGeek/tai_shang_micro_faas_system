defmodule FunctionServerBasedOnArweave.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  alias FunctionServerBasedOnArweave.{Repo, Users.User}

  import Ecto.Query

  @type t :: %User{}

  schema "users" do
    field :role, :string, null: false, default: "user"

    pow_user_fields()

    timestamps()
  end

  @spec changeset_role(Ecto.Schema.t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset_role(user_or_changeset, attrs) do
    user_or_changeset
    |> Ecto.Changeset.cast(attrs, [:role])
    |> Ecto.Changeset.validate_inclusion(:role, ~w(user admin))
  end

  ##
  ## FunctionServerBasedOnArweave.Users.User.create_admin(%{email: "root@gmail.com", password: "12345678", password_confirmation: "12345678"})
  ##
  @spec create_admin(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def create_admin(params) do
    %User{}
    |> User.changeset(params)
    |> User.changeset_role(%{role: "admin"})
    |> Repo.insert()
  end

  @spec set_admin_role(t()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def set_admin_role(user) do
    user
    |> User.changeset_role(%{role: "admin"})
    |> Repo.update()
  end

  @spec is_admin?(t()) :: boolean()
  def is_admin?(%{role: "admin"}), do: true
  def is_admin?(_any), do: false

  def get_by_email(email) do
    Repo.one(from u in User, where: u.email == ^email)
  end
end
