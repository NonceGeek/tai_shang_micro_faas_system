defmodule CodesOnChain.SoulCard.DataHandler do
  @moduledoc """
    Handle SoulCard Data!
  """

  alias Components.{KVHandler, ModuleHandler, GithubFetcher, MsgHandler, Ipfs}
  alias CodesOnChain.SoulCard.{TemplateManager, UserManager}
  @white_map %{
    WeLightProject: [
      "tai_shang_micro_faas_system",
      "Tai-Shang-Soul-Card"
    ]
  }

  def get_module_doc(), do: @moduledoc


  def get_github_white_map() do
    KVHandler.get("github_repos_white_map", ModuleHandler.get_module_name(__MODULE__))
  end

  @doc """
  OUTPUT Example:

    %{
      WeLightProject: %{
        if_in_owner: true,
        repo_list: [
          %{if_in: true, name: "tai_shang_micro_faas_system"},
          %{if_in: true, name: "Tai-Shang-Soul-Card"}
        ]
      }
    }
  """
  @spec analyze_github(String.t(), String.t()) :: list
  def analyze_github(addr, username_or_userid) do
    payload =
      "github_repos_white_map"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> Enum.map(fn {owner, repo_list} ->
        {res, if_in_owner} =
          do_analyze_github(username_or_userid, owner, repo_list)
        {owner, %{repo_list: res, if_in_owner: if_in_owner}}
      end)
      |> Enum.into(%{})
    # KVHandler.put(addr, payload, ModuleHandler.get_module_name(__MODULE__))

    payload
  end

  def analyze_github(addr, username_or_userid, "only_org") do
    payload_in_database = KVHandler.get(addr, ModuleHandler.get_module_name(__MODULE__))
      "github_repos_white_map"
      |> KVHandler.get(ModuleHandler.get_module_name(__MODULE__))
      |> Enum.map(fn {owner, repo_list} ->
        check_record =
          payload_in_database
          |> Map.get(owner)
          |> Map.get(:if_in_owner)
        if is_nil(check_record) or check_record == false  do
          {_res, if_in_owner} =
            do_analyze_github(username_or_userid, owner, repo_list)
            {owner, %{if_in_owner: if_in_owner}}
        else
          {owner, %{if_in_owner: true}}
        end
      end)
      |> Enum.into(%{})
  end

  def do_analyze_github(username_or_userid, owner, repo_list) do
    Enum.reduce(repo_list, {[], false}, fn repo, {acc, if_in_owner} ->
      if_in = GithubFetcher.in_repo?(username_or_userid, owner, repo)
      {acc ++ [%{name: repo, if_in: if_in}], if_in_owner or if_in}
    end)
  end


  def init_github_repos_white_map() do
    github_repos_white_map = @white_map
    KVHandler.put("github_repos_white_map", github_repos_white_map, ModuleHandler.get_module_name(__MODULE__))
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
      {:ok, :pass}
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

  # +-
  # | funs about signature
  # +-

  defdelegate rand_msg,  to: MsgHandler

  # +-
  # | funcs about render and save.
  # +-

  def render_and_put_to_ipfs(addr, role, template_id) do
    {:ok, %{"Hash" => hash}} =
      addr
      |> render(role, template_id)
      |> Ipfs.put_data()
    "https://leeduckgo233.infura-ipfs.io/#{hash}"
  end
  def render(addr, role, template_id) do
    template =
      template_id
      |> TemplateManager.get_by_id()
      |> Base.decode64!()
    payload =
      addr
      |> UserManager.get_user()
      |> Map.get(String.to_atom(role))
    do_render(addr, payload, "user", template)
  end

  def do_render(addr,  %{payload: payload}, "user", template) do
    %{
      basic_info: %{social_links: %{github_link: github_link}} = basic_info,
      awesome_things: awesome_things,
      daos_joined: daos_joined
    } = payload
    template
    |> handle_basic_info(basic_info, "user")
    |> handle_awesome_things(awesome_things)
    |> handle_daos_joined(daos_joined)
    |> handle_white_list(addr, github_link)
    |> handle_addr(addr)
  end

  def handle_basic_info(template, basic_info, "user") do
    Enum.reduce(basic_info, template, fn {k, v}, acc ->
      k_str = Atom.to_string(k)
      case k_str do
        "social_links" ->
          Enum.reduce(v, acc, fn {k_2, v_2}, acc_2 ->
            k_str_2 =
              k_2
              |> Atom.to_string()
              |> String.replace(" ", "")
            String.replace(acc_2, "{#{k_str_2}}", v_2)
          end)
        "skills" ->
          String.replace(acc, "{#{k_str}}", Poison.encode!(v))
        _ ->
          String.replace(acc, "{#{k_str}}", v)
      end
    end)
  end

  def handle_awesome_things(template, awesome_things) do
    String.replace(template, "{awesome_things}", Poison.encode!(awesome_things))
  end

  def handle_daos_joined(template, daos_joined) do
    payloads = Enum.map(daos_joined, fn dao_addr ->
      %{dao: %{payload: %{basic_info: %{name: name, avatar: avatar}}}} =
        UserManager.get_user(dao_addr)
      %{
        name: name,
        avatar: avatar
      }
    end)
    String.replace(template, "{daos_joined}", Poison.encode!(payloads))
  end

  def get_github_username(github_link) do
    github_link
    |> String.split("/")
    |> Enum.fetch!(-1)
  end

  def handle_white_list(template, addr, github_link) do
    username = get_github_username(github_link)
    payloads =
      addr
      |> analyze_github(username)
      |> Enum.reduce([], fn {_k, %{repo_list: repo_list}}, acc ->
        acc ++ repo_list
      end)
      |> Enum.map(fn %{name: name} ->
        %{title: name, link: "https://baidu.com"}
      end)
      String.replace(template, "{project_whitelist}", Poison.encode!(payloads))
  end

  def handle_addr(template, addr) do
    String.replace(template, "{addr}", addr)
  end

end
