defmodule Components.Contract do
  alias Components.Contract, as: Ele
  alias Components.NFT
  alias TaiShangMicroFaasSystem.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "contract" do
    field :addr, :string
    field :abi, {:array, :map}
    field :chain_info, :map # including endpoint & api_explorer
    field :last_block, :integer, default: 0
    has_many :nfts, NFT
    timestamps()
  end

  def get_all() do
    Repo.all(Ele)
  end

  def preload(ele) do
    Repo.preload(ele, [:nfts])
  end

  def get_by_id(id) do
    Repo.get_by(Ele, id: id)
  end

  def get_by_addr(addr) do
    Repo.get_by(Ele, addr: addr)
  end

  def create_without_repeat(%{addr: addr} = attrs) do
    contract = get_by_addr(addr)

    if is_nil(contract) do
      create(attrs)
    else
      {:ok, contract}
    end
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Ele{} = ele, attrs) do
    ele
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(%Ele{} = ele) do
    Ele.changeset(ele, %{})
  end

  @doc false
  def changeset(%Ele{} = ele, attrs) do
    ele
    |> cast(attrs, [:addr, :abi, :chain_info, :last_block])
    |> update_change(:addr, &String.downcase/1)
    |> unique_constraint(:addr)
  end

end
