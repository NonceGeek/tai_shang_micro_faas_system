defmodule FunctionServerBasedOnArweave.OnChainCode do

  use Ecto.Schema
  import Ecto.Changeset
  alias FunctionServerBasedOnArweave.OnChainCode, as: Ele
  alias FunctionServerBasedOnArweave.CodeFetchers.Gist
  alias FunctionServerBasedOnArweave.CodeFetchers.NFT
  alias FunctionServerBasedOnArweave.Repo

  require Logger

  @rejected_func_list [:__info__, :module_info]
  @sleep_time 2_000

  schema "on_chain_code" do
    field :name, :string
    field :tx_id, :string
    field :description, :string
    field :code, :string
    field :type, :string, default: "ar"
    # field :method_name, :string
    # field :output, :string

    timestamps()
  end

  def get_all(), do: Repo.all(Ele)
  def get_by_id(id), do: Repo.get_by(Ele, id: id)

  def get_by_name(name), do:  Repo.get_by(Ele, name: name)
  def get_by_tx_id(tx_id), do: Repo.get_by(Ele, tx_id: tx_id)


  def create_or_query_by_tx_id(tx_id, type \\ "ar") do
    try do
      ele = get_by_tx_id(tx_id)
      if is_nil(ele) == true do
        do_create_or_query_by_tx_id(tx_id, type)
        {:ok, %{content: code}} = do_create_or_query_by_tx_id(tx_id, type)
        Logger.info(code)
        Ele.create_by_payload_and_tx_id(code, tx_id, type)
      else
        {:ok, ele}
      end
    rescue
      error ->
        {:error, inspect(error)}
    end
  end

  def do_create_or_query_by_tx_id(tx_id, "ar") do
    ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), tx_id)
  end

  def do_create_or_query_by_tx_id(tx_id, "gist") do
    Gist.get_from_gist(tx_id)
  end

  def do_create_or_query_by_tx_id(tx_id, "nft") do
    NFT.get_from_nft(tx_id)
  end

  def create_by_payload_and_tx_id(code, tx_id, type) do
    # Code.eval_string(code)
    Logger.info(code)
    name = get_module_name_from_code(code)
    # save file to local
    File.write!("lib/codes_on_chain/#{name}.ex", code)
    # reload module
    Process.sleep(@sleep_time)
    IEx.Helpers.r(String.to_atom("Elixir.#{name}"))
    # load code by local file
    description = get_description_from_name(name)
    # create it in database
    Ele.create(%{
      name: name,
      tx_id: tx_id,
      description: description,
      code: code,
      type: type
    })
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def changeset(code_loader, attrs \\ %{}) do
    code_loader
    |> cast(attrs, [:name, :tx_id, :description, :code, :type])
    # |> validate_required([:name])
  end

  # +
  # | spec funcs
  # +


  def load_code(code)do
    Code.eval_string(code)
    # module_name = get_module_name_from_code(code)
    # module_name.module_info
  end
  def remove_code_by_name(name) do
    name
    |> get_by_name()
    |> Repo.delete
  end
  def get_functions(name) do
    %{exports: raw_functions} =
      get_module_info(name)
    raw_functions
    |> Enum.reject(fn {key, _value} ->
      key in @rejected_func_list
    end)
    |> Enum.into(%{})
  end
  def get_module_info(name) do
    "Elixir.#{name}"
    |> String.to_atom()
    |> apply(:module_info, [])
    |> Enum.into(%{})
  end

  @spec get_module_name_from_code(String.t()) :: String.t()
  def get_module_name_from_code(code) do
    code
    |> String.split("\n")
    |> Enum.fetch!(0)
    |> String.replace("defmodule", "")
    |> String.replace("do", "")
    |> String.replace(" ", "")
    # |> String.to_atom()
  end

  def get_description_from_name(name) do
    "Elixir.#{name}"
    |> String.to_atom()
    |> apply(:get_module_doc, [])
  end
end
