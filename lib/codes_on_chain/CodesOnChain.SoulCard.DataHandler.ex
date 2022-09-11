defmodule CodesOnChain.SoulCard.DataHandler do
  @moduledoc """
    Handle SoulCard Data!
  """

  def get_module_doc(), do: @moduledoc


  @spec handle_data(map(), String.t()) :: any()
  def handle_data(payload, "dao") do

  end
  def handle_data(payload, "user") do

  end

    @doc """
    see USER regular data in:

    > https://gist.github.com/leeduckgo/b4975e6ad2836ffb9cd0a190efb80737

    see DAO regular data in:

    > https://gist.github.com/leeduckgo/220087607d69490980ba59c235b86f59
  """


  def check_format(data, "dao") do
    data_handled = ExStructTranslator.to_atom_struct(data)
    with {:ok,  [basic_info, awesome_things, _partners, core_members, members, sub_daos]} <- check_data_format(data_handled, :dao),
    {:ok, _data} <- check_data_format(basic_info, :basic_info, :dao),
    # todo: check Partners
    {:ok, _data} <- check_data_format(awesome_things, :awesome_things),
    {:ok, _data} <- check_keys_list_data_format(core_members, :core_members),
    {:ok, _data} <- check_keys_list_data_format(members, :members),
    {:ok, _data} <- check_keys_list_data_format(sub_daos, :sub_daos) do
      {:ok, "all check is passed!"}
    else
      error ->
        error
    end
  end

  def check_format(data, "user") do
    data_handled = ExStructTranslator.to_atom_struct(data)
    with {:ok,  [basic_info, awesome_things, daos_joined]} <- check_data_format(data_handled),
    {:ok, _data} <- check_data_format(basic_info, :basic_info),
    {:ok, _data} <- check_data_format(awesome_things, :awesome_things),
    {:ok, _data} <- check_keys_list_data_format(daos_joined, :daos_joined) do
      {:ok, "all check is passed!"}
    else
      error ->
        error
    end
  end

  # +-
  # | check data format of user/DAO
  # +-

  def check_data_format(data) do
    try do
      %{
        basic_info: basic_info,
        awesome_things: awesome_things,
        daos_joined: daos_joined

      } = data
      {:ok, [basic_info, awesome_things, daos_joined]}
    rescue
    _ ->
      {:error, "data's basic structure is inregular."}
    end
  end

  def check_data_format(data, :dao) do
    try do
      %{
        basic_info: basic_info,
        awesome_things: awesome_things,
        partners: partners,
        core_members: core_members,
        members: members,
        sub_daos: sub_daos
      } = data
      {:ok, [basic_info, awesome_things, partners, core_members, members, sub_daos]}
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

  def check_data_format(basic_info_data, :basic_info, :dao) do
    try do
      %{
        name: _name,
        slogan: _slogan,
        social_links: _social_links,
        avatar: _avatar,
        location: _location,

        homepage: _homepage,
        contract_addresses: _contract_addrs
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

  def check_keys_list_data_format(data, data_name) do
    res = Enum.reduce(data, true, fn elem, acc -> is_binary(elem) and acc end)
    if res do
      {:ok, :pass}
    else
      {:error, "#{data_name} is inregular"}
    end
  end

end
