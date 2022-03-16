defmodule FunctionServerBasedOnArweave.OnChainCode do

  use Ecto.Schema
  import Ecto.Changeset
  alias FunctionServerBasedOnArweave.OnChainCode, as: Ele
  alias FunctionServerBasedOnArweave.Repo

  @rejected_func_list [:__info__, :module_info]

  schema "on_chain_code" do
    field :name, :string
    field :tx_id, :string
    field :description, :string
    field :code, :string
    # field :method_name, :string
    # field :output, :string

    timestamps()
  end

  def get_all(), do: Repo.all(Ele)
  def get_by_id(id), do: Repo.get_by(Ele, id: id)

  def get_by_name(name), do:  Repo.get_by(Ele, name: name)
  def get_by_tx_id(tx_id), do: Repo.get_by(Ele, tx_id: tx_id)


  def create_or_query_by_tx_id(tx_id) do
    ele = get_by_tx_id(tx_id)

    if is_nil(ele) == true do
      {:ok, %{content: code}} = ArweaveSdkEx.get_content_in_tx(ArweaveNode.get_node(), tx_id)
      Ele.create_by_payload_and_tx_id(code, tx_id)
    else
      {:ok, ele}
    end
  end

  def create_by_payload_and_tx_id(code, tx_id) do
    Code.eval_string(code)
    name = get_module_name_from_code(code)
    # save file to local
    File.write!("lib/codes_on_chain/#{name}.ex", code)
    description = get_description_from_name(name)
    Ele.create(%{
      name: name,
      tx_id: tx_id,
      description: description,
      code: code
    })
    # description = get_module_description_from_code(code)
  end

  def create(attrs \\ %{}) do
    %Ele{}
    |> Ele.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def changeset(code_loader, attrs \\ %{}) do
    code_loader
    |> cast(attrs, [:name, :tx_id, :description, :code])
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
