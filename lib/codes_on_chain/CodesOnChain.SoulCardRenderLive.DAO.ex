defmodule CodesOnChain.SoulCardRenderLive.DAO do
    @moduledoc """
      Impl a dynamic webpage for DAO user by Snippet!
      Example page:

    """
    use FunctionServerBasedOnArweaveWeb, :live_view
    alias CodesOnChain.{SoulCardRender, SpeedRunFetcher}
    alias Components.{GistHandler, Verifier}
    alias Components.Verifier.MsgHandler
    alias Components.KVHandler.KVRouter
    alias Components.{KVHandler, MirrorHandler}


    @template_gist_id_example "1a301c084577fde54df73ced3139a3cb"

    def get_module_doc, do: @moduledoc

    @impl true
    def render(assigns) do
      # template = init_html(assigns.template_gist_id)
      # # template = File.read!("template.html")
      # quoted = EEx.compile_string(template, [engine: Phoenix.LiveView.HTMLEngine])

      # {result, _bindings} = Code.eval_quoted(quoted, assigns: assigns)
      # result
      ~H"""
        <html>

        <head>
          <title>SoulCard</title>
          <style>
        /* 重置浏览器自定义的样式 */
        * {
          margin: 0;
          padding: 0;
        }


        /* 本页作为 iframe 嵌入到别的页面
        要和父页面宽度相同 */
        body {
          width: 510px;
          height: 370px;
          overflow: hidden;
        }

        /* 顶部的按钮组 */
        .actions {
          display: flex;
          align-items: center;
        }

        .actions .button {
          background: linear-gradient(to right, #79D5A8, #D5F97D);
          border-radius: 4px;
          border: 0;
          padding: 4px 6px;
          font-size: 12px;
        }

        .button:first-child {
          margin-right: 8px;
        }

        /* namecard 和上方容器间的距离 */
        #container {
          margin-top: 8px;
        }

        #namecard_0 {
          position: relative;
          width: 600px;
          height: 400px;
          background: #0C0F17;
        }

        #namecard_0 .left {
          width: 33.33%;
          height: 100%;
          display: flex;
          flex-direction: column;
          align-items: flex-start;
        }

        .left #avatar {
          width: 100%;
          height: 50%;
          cursor: pointer;
        }

        .left .footer {
          width: 100%;
          height: 50%;
          background: #aaa;
          color: #fff;
          font-size: 13px;
          display: flex;
          flex-direction: column;
          justify-content: space-around;
          align-items: center;
        }

        .footer img {
          height: 16px;
          width: auto;
        }

        .footer .social-icon:last-child {
          margin-left: .5em;
        }

        .footer .speedrun-infos {
          display: flex;
          flex-direction: column;
          align-items: center;
        }

        .right {
          width: 66.66%;
          height: 100%;
          box-sizing: border-box;
          padding: 50px;
          display: flex;
          flex-direction: column;
          justify-content: space-between;
          background: #333;
          color: #fff;
        }

        .right .top #name {
          margin-bottom: 10px;
          font-weight: bold;
          font-size: 32px;
        }

        .right .top #address {
          font-size: 12px;
          margin-top: 20px;
          color: #888;
        }

        .right .content {
          font-size: 16px;
        }

        .right .content #abilities {
          margin-top: 10px;
        }

        .right .button {
          box-sizing: border-box;
          padding: 10px 15px;
          background: #1D1D1D;
          box-shadow: 2px 2px 4px rgba(0, 0, 0, 0.25);
          border-radius: 10em;
          font-size: 16px;
          color: #53C78E;
        }

        /* 第二个 namecard
        只有头像和用户名 */
        #namecard2 {
          width: 600px;
          height: 400px;
          box-sizing: border-box;
          padding: 20px;
          background: #0C0F17;
          display: flex;
          flex-direction: column;
          justify-content: space-evenly;
          align-items: flex-start;
        }

        #namecard2 .top {
          display: flex;
          justify-content: space-between;
          align-items: flex-start;
        }

        #namecard2 .top .top-left.dao-homepage {
          width: 30%;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        .top-left.dao-homepage .dao-logo {
          width: 100px;
          height: 100px;
          border-radius: 5px;
          overflow: hidden;
        }

        .top-left.dao-homepage .dao-name {
          margin-top: 10px;
          width: 100px;
          height: 2em;
          border-radius: 2px;
          display: flex;
          justify-content: center;
          align-items: center;
          background-color: #fff;
          color: #A112BB;
        }

        #namecard2 .top .top-right.infos {
          margin-left: 30px;
          width: 300px;
        }

        .top-right.infos .text {
          font-family: 'Inter';
          font-weight: 400;
          font-size: 32px;
          line-height: 39px;
          text-align: right;
          color: #FFFFFF;
        }

        .top-right.infos .text.main {
          margin-bottom: 20px;
        }

        .bottom.nfts .nfts-title {
          font-family: 'Inter';
          font-weight: 400;
          font-size: 18px;
          margin-bottom: 10px;
          color: #FFFFFF;
        }

        .bottom.nfts .nfts-imgs {
          width: 50px;
          display: flex;
          justify-content: flex-start;
          gap: 10%;
        }
       /* namecard_1 */
        #namecard_1 {
          width: 600px;
          height: 400px;
          box-sizing: border-box;
          padding: 40px;
          background: #0C0F17;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          color: #fff;
        }

        #namecard_1 .article {
          width: 70%;
          background: linear-gradient(to right, #79D5A8, #D5F97D);
          box-sizing: border-box;
          border-radius: 4px;
          padding: 1px;
          cursor: pointer;
        }

        #namecard_1 .article .text {
          display: inline-block;
          width: 100%;
          height: 100%;
          box-sizing: border-box;
          padding: 10px;
          border-radius: 4px;
          background-color: #0C0F17;
        }

        #namecard_1 .article:not(:first-child) {
          margin-top: 1em;
        }

        #namecard_1 .article-1 .text:hover {
          background-color: #fff;
          color: #007aff;
        }

        #namecard_1 .article-2 .text:hover {
          background-color: #fff;
          color: #34c759;
        }

        #namecard_1 .article-3 .text:hover {
          background-color: #fff;
          color: #ff2d55;
        }

       /* namecard_2 */
        #namecard_2 {
          width: 600px;
          height: 400px;
          box-sizing: border-box;
          padding: 40px;
          background: #0C0F17;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          color: #fff;
        }

        #namecard_2 .article {
          width: 70%;
          background: linear-gradient(to right, #79D5A8, #D5F97D);
          box-sizing: border-box;
          border-radius: 4px;
          padding: 1px;
          cursor: pointer;
        }

        #namecard_2 .article .text {
          display: inline-block;
          width: 100%;
          height: 100%;
          box-sizing: border-box;
          padding: 10px;
          border-radius: 4px;
          background-color: #0C0F17;
        }

        #namecard_2 .article:not(:first-child) {
          margin-top: 1em;
        }

        #namecard_2 .article-1 .text:hover {
          background-color: #fff;
          color: #007aff;
        }

        #namecard_2 .article-2 .text:hover {
          background-color: #fff;
          color: #34c759;
        }

        #namecard_2 .article-3 .text:hover {
          background-color: #fff;
          color: #ff2d55;
        }

        /* namecard_3 */
        #namecard_3 {
          width: 600px;
          height: 400px;
          box-sizing: border-box;
          padding: 40px;
          background: #0C0F17;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          color: #fff;
        }

        #namecard_3 .article {
          width: 70%;
          background: linear-gradient(to right, #79D5A8, #D5F97D);
          box-sizing: border-box;
          border-radius: 4px;
          padding: 1px;
          cursor: pointer;
        }

        #namecard_3 .article .text {
          display: inline-block;
          width: 100%;
          height: 100%;
          box-sizing: border-box;
          padding: 10px;
          border-radius: 4px;
          background-color: #0C0F17;
        }

        #namecard_3 .article:not(:first-child) {
          margin-top: 1em;
        }

        #namecard_3 .article-1 .text:hover {
          background-color: #fff;
          color: #007aff;
        }

        #namecard_3 .article-2 .text:hover {
          background-color: #fff;
          color: #34c759;
        }

        #namecard_3 .article-3 .text:hover {
          background-color: #fff;
          color: #ff2d55;
        }

        /* namecard_3 */
        #namecard_4 {
          width: 600px;
          height: 400px;
          box-sizing: border-box;
          padding: 40px;
          background: #0C0F17;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          color: #fff;
        }

        #namecard_4 .article {
          width: 70%;
          background: linear-gradient(to right, #79D5A8, #D5F97D);
          box-sizing: border-box;
          border-radius: 4px;
          padding: 1px;
          cursor: pointer;
        }

        #namecard_4 .article .text {
          display: inline-block;
          width: 100%;
          height: 100%;
          box-sizing: border-box;
          padding: 10px;
          border-radius: 4px;
          background-color: #0C0F17;
        }

        #namecard_4 .article:not(:first-child) {
          margin-top: 1em;
        }

        #namecard_4 .article-1 .text:hover {
          background-color: #fff;
          color: #007aff;
        }

        #namecard_4 .article-2 .text:hover {
          background-color: #fff;
          color: #34c759;
        }

        #namecard_4 .article-3 .text:hover {
          background-color: #fff;
          color: #ff2d55;
        }
        /* 所有图片与父元素宽高相同 */
        img {
          width: 100%;
          height: 100%;
        }

        /* 设置所有链接的通用样式 */
        a:link {
          color: white;
          text-decoration: none;
        }

        a:visited {
          color: white;
          text-decoration: none;
        }

        a:hover {
          color: white;
          text-decoration: none;
        }
          </style>
        </head>
        <body>
          <div class="actions">
            <button class="button" onclick="copy()">copy as html!</button>
            <button class="button" onclick="flip()">flip page!</button>
          </div>
          <div id="container">

            <!-- page 0x00 basic info -->
            <div id="namecard_0" class="card" style="display: flex;">
              <div class="left">
                <div id="avatar" onclick="copy()">
                  <img src={assigns.basic_info[:avatar]}>
                </div>
                <div class="footer">
                  <div class="social-icons">

                    <%= if !is_nil(assigns.basic_info[:github_link]) do %>
                    <a class="social-icon" target="_blank" href={assigns.basic_info[:github_link]}>
                      <img src="https://cdn.cdnlogo.com/logos/g/55/github.svg">
                    </a>
                    <% end %>
                    <%= if !is_nil(assigns.basic_info[:mirror_link]) do %>
                    <a class="social-icon" target="_blank" href={assigns.basic_info[:mirror_link]}>
                      <img src="https://tva1.sinaimg.cn/large/e6c9d24egy1h2p3vznvx3j2069069glf.jpg">
                    </a>
                    <% end %>
                    <%= if !is_nil(assigns.basic_info[:twitter]) do %>
                    <a class="social-icon" target="_blank" href={assigns.basic_info[:twitter]}>
                      <img src="https://cdn.cdnlogo.com/logos/t/96/twitter-icon.svg">
                    </a>
                    <% end %>
                  </div>
                  <div class="email">
                  <%= if !is_nil(assigns.basic_info[:homepage]) do %>
                    <div >
                      <a href={ assigns.basic_info[:homepage] } target="_blank">
                        <%= assigns.basic_info[:homepage] %>
                      </a>
                    </div>
                  <% end %>
                  <%= if !is_nil(assigns.basic_info[:email]) do %>
                    <div >
                    <%= assigns.basic_info[:email] %>
                    </div>
                  <% end %>
                  </div>
                </div>
              </div>
              <div class="right">
                <div class="top">
                  <div id="name"><%= assigns.basic_info[:name] %></div>
                  <%= if !is_nil(assigns.basic_info[:slogan]) do %>
                  <%= assigns.basic_info[:slogan] %>
                  <% end %>
                  <br><br>

                  <%= if !is_nil(assigns.basic_info[:addr]) do %>
                  Ethereum Address:
                  <a id="address" target="_blank"
                    href={"https://zapper.fi/account/#{assigns.basic_info.addr}"}>
                    <%= assigns.basic_info.addr %>
                  </a>
                  <% end %>
                  <%= if !is_nil(assigns.basic_info[:addr_starcoin]) do %>
                  Starcoin Address:
                  <a id="address" target="_blank">
                    <%= assigns.basic_info.addr_starcoin %>
                  </a>
                  <% end %>
                </div>

              </div>
            </div>

            <!--page 0x01 create things -->

            <%= if !is_nil(assigns[:create_things]) do %>
              <div id="namecard_1" class="card" style="display: none;">
                <h1>Awesome create things!</h1><br>
                <%= Enum.map(assigns[:create_things], fn elem -> %>
                  <p>Title: <%= elem.title %></p>
                  <p>Description: <%= elem.description %></p>
                  <p>Link: <a href={elem.link} target="_blank"><%= elem.link %></a></p>
                  <hr>
                <% end) %>
              </div>
            <% end %>

            <!--page 0x02 core members -->

            <%= if !is_nil(assigns[:core_members]) do %>
              <div id="namecard_2" class="card" style="display: none;">
                <h1>Core Members</h1><br>
                <%= Enum.map(assigns[:core_members], fn elem -> %>
                  <p>Title: <%= elem.name %></p>
                  <p>Description: <%= elem.slogan %></p>
                  <p>Link: <a href={elem.awesome_link} target="_blank"><%= elem.awesome_link %></a></p>
                  <!--<p>avatar: <%= elem.avatar %></p>-->
                  <hr>
                <% end) %>
              </div>
            <% end %>

            <!--page 0x03 partners -->

            <%= if !is_nil(assigns[:partners]) do %>
              <div id="namecard_3" class="card" style="display: none;">
                <h1>Partners</h1><br>
                <%= Enum.map(assigns[:partners], fn elem -> %>
                  <p>Title: <%= elem.name %></p>
                  <p>Description: <%= elem.description %></p>
                  <p>Link: <a href={elem.link} target="_blank"><%= elem.link %></a></p>
                  <hr>
                <% end) %>
              </div>
            <% end %>

            <!--page 0x04 connect us -->


            <%= if !is_nil(assigns[:qr_code]) do %>
            <div id="namecard_4" class="card" style="display: none;">
              <h1>Contact us</h1><br>
              <img src={assigns[:qr_code]} style="width:300px">
            </div>
          <% end %>

          </div>

          <script>
            function copy() {
              var payload = document.documentElement.innerHTML;
              let index = payload.indexOf("<title>");
              let copyBtn = "<button onclick='copy()'>copy as html!</button>"
              full_html = "<html><head>" + payload.slice(index).replace() + "</html>";

              navigator.clipboard.writeText(full_html);
            }

            // 函数能够正常运行的前提：
            // 最初只有一个 .card 元素的 display 是 flex
            // 其余都是 none
            function flip() {
              var face = document.querySelectorAll('.card')

              for (var i = 0; i < face.length; i++) {

                // 找到当前显示的那个 namecard 的序号
                if (face[i].style.display === 'flex') {

                  // 记录下一个 namecard 的序号
                  var j = (i + 1) % face.length

                  // 设置下一个 namecard 的 display 为 flex
                  // 其余的都设置为 none
                  for (var k = 0; k < face.length; k++) {
                    if (k === j) {
                      face[k].style.display = 'flex'
                      console.log("flip to page " + k);
                    } else {
                      face[k].style.display = 'none'
                    }
                  }

                  // 设置完毕，结束循环
                  return
                }
              }
            }
          </script>

          <iframe hidden="" height="0" width="0" src="/phoenix/live_reload/frame"></iframe>
          </body>

        </html>
      """
  end

  def regist_route() do
    KVRouter.put_routes(
      [
        ["/soulcard/dao", "SoulCardRenderLive.DAO", "index"]
      ]
    )
  end

  def remove_route(addr, msg, signature) do
    # update user info when the key does not exist
    with true <- Verifier.verify_message?(addr, msg, signature),
      true <- MsgHandler.time_valid?(msg) do
      KVRouter.del_routes("/soulcard/dao")
    else
      error ->
        {:error, inspect(error)}
    end
  end

  @doc """
   there are two ways to render soulcard: \n
   * gist_id -> render by metadata in gist \n
   * addr -> render by metadata in database \n
   Logic: mount() -> mount_by_payload() -> do_mount_by_payload()
  """
  @impl true
  def mount(%{"gist_id" => gist_id}, _session, socket) do
    %{files: payload} =
      gist_id
      |> GistHandler.get_gist()
      |> GistHandler.del_types_from_names()

    mount_by_payload(payload, socket)
  end

  @impl true
  def mount(%{"addr" => addr}, _session, socket) do
    # Step 0x1. Fetch data in database
    %{dao: %{payload: payload}} = KVHandler.get(addr, "UserManager")
    # Step 0x2. mount by gist_id
    mount_by_payload(payload, socket)
  end

  def mount_by_payload(payload, socket) do
    %{
      basic_info: %{content: basic_info},
    } = payload
    create_things = get_value(payload, :create_things)
    core_members = get_value(payload, :core_members)
    partners = get_value(payload, :partners)
    do_mount_by_payload(socket, basic_info, create_things, core_members, partners)
  end

  def get_value(payload, key) do
    res = Map.get(payload, key)
    if is_nil(res) do
      nil
    else
      %{content: content} = res
      content
    end
  end

  defp do_mount_by_payload(socket, basic_info, articles, members, partners) do
    %{qr_code: qr_code} = basic_info
    {
      :ok,
      socket
      |> assign(:basic_info, basic_info) # page 0x01: basic infos
      |> assign(:create_things, articles) # page 0x02: DAO create things
      |> assign(:core_members, members) # page 0x03: DAO members
      |> assign(:partners, partners) # page 0x04: partners
      |> assign(:qr_code, qr_code) # page 0x05: contact_us
    }
  end

  def init_html(template_gist_id) do
    %{
      files: files
    } = GistHandler.get_gist(template_gist_id)
    {_file_name, %{content: content}} = Enum.fetch!(files, 0)
    content
  end

  @impl true
  def handle_event(_key, _params, socket) do
    {:noreply, socket}
  end
end
