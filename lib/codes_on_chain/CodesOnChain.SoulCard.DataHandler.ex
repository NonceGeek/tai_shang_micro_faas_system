defmodule CodesOnChain.SoulCard.DataHandler do
  @moduledoc """
    Generate SoulCard Data!
  """
  alias Components.Ipfs

  def get_module_doc(), do: @moduledoc


  @spec handle_data(map(), String.t()) :: any()
  def handle_data(payload, "dao") do

  end
  def handle_data(payload, "user") do

  end

  def check_format(data, "dao") do
    try do
      {:ok, :todo}
    rescue
    _ ->
      {:error, "your data is inregular: #{inspect(data)}"}
    end
  end


  #+-
  #| check data foramt of user
  #+-
  @doc """
    see regular data in:

    > https://gist.github.com/leeduckgo/b4975e6ad2836ffb9cd0a190efb80737
  """
  def check_format(data, "user") do
    data_handled = ExStructTranslator.to_atom_struct(data)
    with {:ok,  [basic_info, awesome_things, dao_joined]} <- check_data_format(data_handled),
    {:ok, _data} <- check_data_format(basic_info, :basic_info),
    {:ok, _data} <- check_data_format(awesome_things, :awesome_things),
    {:ok, _data} <- check_data_format(dao_joined, :dao_joined) do
      {:ok, "all check is passed!"}
    else
      error ->
        error
    end
  end

  def check_data_format(data) do
    try do
      %{
        basic_info: basic_info,
        awesome_things: awesome_things,
        dao_joined: dao_joined

      } = data
      {:ok, [basic_info, awesome_things, dao_joined]}
    rescue
    _ ->
      {:error, "data's basic structure is inregular."}
    end
  end

  def check_data_format(basic_info_data, :basic_info) do
    try do
      %{
        name: _name,
        slogan: _slogan,
        social_links: _social_links,
        avatar: _avatar,
        skills: _skills,
        location: _location
    } = basic_info_data
      {:ok, basic_info_data}
    rescue
      _ ->
        {:error, "basic_info is inregular."}
    end
  end

  def check_data_format(awesome_things_info, :awesome_things) do
    try do
      Enum.each(awesome_things_info, fn %{title: _title, link: _link} ->
        :pass
      end)
    rescue
      _ ->
        {:error, "awesome_things_info is inregular"}
    end
  end

  def check_data_format(dao_joined, :dao_joined) do
    res = Enum.reduce(dao_joined, true, fn elem, acc -> is_binary(elem) and acc end)
    if res do
      {:ok, :pass}
    else
      {:error, "dao_joined is inregular"}
    end
  end
end
