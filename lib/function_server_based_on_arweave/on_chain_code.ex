defmodule FunctionServerBasedOnArweave.OnChainCode do
  use Ecto.Schema
  import Ecto.{Changeset, Query}
  alias FunctionServerBasedOnArweave.OnChainCode, as: Ele
  alias FunctionServerBasedOnArweave.CodeFetchers.Gist
  alias FunctionServerBasedOnArweave.CodeFetchers.NFT
  alias FunctionServerBasedOnArweave.Repo
  alias Components.Ipfs

  require Logger

  @rejected_func_list [:__info__, :module_info]

  schema "on_chain_code" do
    field :name, :string
    field :tx_id, :string
    field :description, :string
    field :code, :string
    field :type, :string, default: "ar" # ar/ipfs/gist
    # field :method_name, :string
    # field :output, :string

    timestamps()
  end

  def get_all(), do: Repo.all(Ele)
  def get_by_id(id), do: Repo.get_by(Ele, id: id)

  def get_by_name(name), do: Repo.get_by(Ele, name: name)
  def get_by_tx_id(tx_id), do: Repo.get_by(Ele, tx_id: tx_id)

  def get_all_by_tx_id(tx_id) do
    Ele
    |> where([c], c.tx_id == ^tx_id)
    |> Repo.all()
  end

  def create_or_query_by_tx_id(tx_id, type \\ "ar") do
    try do
      # ele = get_all_by_tx_id(tx_id)
      # IO.puts inspect ele
      # if ele == [] do
      #   {:ok, %{content: code}} = fetch_by_tx_id(tx_id, type)
      #   create_or_update(code, tx_id, type)
      # else
      #   {:ok, %{content: code}} = fetch_by_tx_id(tx_id, type)
      #   create_or_update(code, tx_id, type)
      # end
      {:ok, %{content: code}} = fetch_by_tx_id(tx_id, type)
      create_or_update(code, tx_id, type)

    rescue
      error ->
        {:error, inspect(error)}
    end
  end

  # TODO: Optimize Here.
  def create_or_update(codes, tx_id, type) do
    if type in ["gist", "ipfs", "ar"] do
      # TODO: Update Logic that if exist then update else create
       try do
        :ok = Enum.each(codes, fn code ->
          record =
            code
            |> get_module_name_from_code()
            |> get_by_name()
          Ele.create_or_update_by_payload_and_tx_id(code, tx_id, type, record)
        end)
        {:ok, "add all codes in gist success"}
      rescue
        error ->
          {:error, inspect(error)}
      end
    # else
    #   record =
    #     codes
    #     |> get_module_name_from_code()
    #     |> get_by_name()
    #   Ele.create_or_update_by_payload_and_tx_id(codes, tx_id, type, record)
    end
  end

  @spec fetch_by_tx_id(String.t(), String.t()) :: {:error, binary} | {:ok, %{content: map()}}
  def fetch_by_tx_id(tx_id, "ar") do
    ArweaveSdkEx.get_content_in_tx(Constants.get_arweave_node(), tx_id)
  end

  def fetch_by_tx_id(tx_id, "gist") do
    Gist.get_from_gist(tx_id)
  end

  def fetch_by_tx_id(cid, "ipfs") do
    {:ok, result} = Ipfs.get_data(cid)
    result
    |> Poison.decode!()
    |> Gist.get_from_gist("ipfs")
  end

  def fetch_by_tx_id(token_id, "nft") do
    token_id
    |> String.to_integer()
    |> NFT.get_from_nft()
  end

  @spec create_or_update_by_payload_and_tx_id(binary, any, any, any) :: {:ok, any} | {:error, any}
  def create_or_update_by_payload_and_tx_id(code, tx_id, type, record \\ nil) do
    # Code.eval_string(code)
    Logger.info("fetching code: #{code}")
    name = get_module_name_from_code(code)
    # save file to local
    File.write!("lib/codes_on_chain/#{name}.ex", code)
    # load code
    # I went ahead with Code.eval_string/2 and while it’s at least an order of magnitude slower than running compiled code, it’s good enough for the current event throughput. The expressions I’ll use are quite small. Basically what would go into the condition of an if control statement.
    # TODO: Code.eval_string_is_slow, so it's better to recompile module after file write.
    Code.eval_string(code)
    description = get_description_from_code(code)
    if is_nil(record) do
      Ele.create(%{
        name: name,
        tx_id: tx_id,
        description: description,
        code: code,
        type: type
      })
      else
        Ele.update(record, %{
          name: name,
          tx_id: tx_id,
          description: description,
          code: code,
          type: type
        })
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

  @doc false
  def changeset(code_loader, attrs \\ %{}) do
    code_loader
    |> cast(attrs, [:name, :tx_id, :description, :code, :type])

    # |> validate_required([:name])
  end

  # +
  # | spec funcs
  # +

  def load_code(code) do
    Code.eval_string(code)
    # module_name = get_module_name_from_code(code)
    # module_name.module_info
  end

  def update_code_by_name(name) do
    record = get_by_name(name)
    with false <- is_nil(record) do
      type = record.type
      tx_id = record.tx_id
      {:ok, %{content: code}} = fetch_by_tx_id(tx_id, type)
      if type == "gist" do
        code = code |> Enum.find(fn x -> get_module_name_from_code(x) == name end)
        if is_binary(code) do
          Ele.create_or_update_by_payload_and_tx_id(code, tx_id, "gist", record)
        end
      else
        Ele.create_or_update_by_payload_and_tx_id(code, tx_id, type, record)
      end
    end
  end

  def remove_code_by_gist(tx_id) do
     get_all()
     |> Enum.filter(fn %{tx_id: tx_id1} ->  tx_id1 == tx_id end)
     |> Enum.map(fn x -> Repo.delete(x) end)
  end
  def remove_code_by_name(name) do
    name
    |> get_by_name()
    |> Repo.delete()
  end

  def get_functions(name) do
    %{exports: raw_functions} = get_module_info(name)

    raw_functions
    |> Enum.reject(fn {key, _value} ->
      key in @rejected_func_list
    end)
    |> Enum.map(fn {name, arity} ->
      "#{name}/#{arity}"
    end)
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

  def get_description_from_code(code) do
    code
    |> String.split("\"\"\"")
    |> Enum.fetch!(1)
    |> String.replace_leading("\n", "")
    |> String.replace_leading(" ", "")
    |> String.replace_trailing(" ", "")
    |> String.replace_trailing("\n", "")
  end

  # def get_description_from_name(name) do
  #   "Elixir.#{name}"
  #   |> String.to_atom()
  #   |> apply(:get_module_doc, [])
  # end
end
