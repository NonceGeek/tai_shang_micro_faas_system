defmodule CodesOnChain.SoulCardRenderLive do
  @moduledoc """
    Test to impl a dynamic webpage by snippet!
  """
  use FunctionServerBasedOnArweaveWeb, :live_view
  alias CodesOnChain.SoulCardRender
  alias Components.GistHandler
  alias Components.KVHandler.KVRouter
  alias Components.KVHandler
  alias Components.ModuleHandler

  @template_gist_id_example "1a301c084577fde54df73ced3139a3cb"
  @default_avatar "https://noncegeek.com/avatars/leeduckgo.jpeg"

  def get_module_doc, do: @moduledoc

  @impl true
  def render(assigns) do
    # template = init_html(assigns.template_gist_id)

    # quoted = EEx.compile_string(template, [engine: Phoenix.LiveView.HTMLEngine])

    # {result, _bindings} = Code.eval_quoted(quoted, assigns: assigns)
    # result
    ~H"""
    <html>
    <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <style>
          .nameCardReverse {
            position: relative;
            width: 786px;
            height: 420px;
            background: #333333;
        }
          div #personImgReverse {
              position: absolute;
              width: 251px;
              height: 251px;
              left: 268px;
              top: 55px;

              background-repeat: no-repeat;
              background-size: cover;
              filter: drop-shadow(2px 2px 9px rgba(0, 0, 0, 0.1));
              border-radius: 50%;
              cursor: pointer;
              /* overflow: hidden;
              display: flex; */
          }
            #p-reverse {
                position: absolute;
                /* width: 155px; */
                height: 39px;
                left: 316px;
                top: 315px;

                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 32px;
                line-height: 39px;
                /* identical to box height */
                color: #FFFFFF;
            }
            #p-reverse-2 {
              position: absolute;
              /* width: 155px; */
              height: 20 px;
              left: 316px;
              top: 350px;

              font-family: 'Inter';
              font-style: normal;
              font-weight: 400;
              font-size: 20px;
              line-height: 39px;
              /* identical to box height */
              color: #FFFFFF;
          }
            div .namecard {
                position: relative;
                width: 786px;
                height: 420px;
                background: #FFFFFF;
            }
            div #personImg {
                position: absolute;
                width: 293px;
                height: 420px;
                left: 0px;
                top: 0px;
                background-repeat: none;
                background-size: cover;
                cursor: pointer;
            }
            /* #personImg :hover {

            } */
            .flip-tip {
                display: none;
                position: absolute;
                background-color: #f9f9f9;
                min-width: 160px;
                box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
            }
            .flip-tip span {
                color: black;
                padding: 12px 16px;
                text-decoration: none;
                display: block;
            }
            #personImg:hover .flip-tip {
                display: block;
            }
            div .footer {
                position: absolute;
                width: 293px;
                height: 63px;
                left: 0px;
                top: 357px;
                background: rgba(51, 51, 51, 0.5);
            }
            .footer img {
                position: absolute;
                /* width: 65px; */
                height: 16px;
                top: 24px;
                display: inline;
            }
            .footer span {
                position: absolute;
                width: 144px;
                height: 15px;
                left: 119px;
                top: 24px;
                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 12px;
                line-height: 15px;
                color: #FFFFFF;
            }
            .right {
                position: absolute;
                width: 493px;
                height: 420px;
                left: 293px;
                top: 0px;
                background: #333333;
            }
            .right #name {
                position: absolute;
                /* width: 159px; */
                height: 39px;
                left: 57px;
                top: 73px;
                font-family: 'Inter';
                font-style: normal;
                font-weight: 600;
                font-size: 32px;
                line-height: 39px;
                color: #FFFFFF;
            }
            .right #address {
                position: absolute;
                width: 74px;
                height: 15px;
                left: 57px;
                top: 121px;
                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 12px;
                line-height: 15px;
                color: #FFFFFF;
                opacity: 0.5;
            }
            .right #about_me {
                position: absolute;
                width: 257px;
                height: 47px;
                left: 58px;
                top: 150px;
                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 16px;
                line-height: 19px;
                color: #FFFFFF;
            }
            .right #abilities {
                position: absolute;
                /* width: 288px; */
                height: 94px;
                left: 58px;
                top: 200px;
                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 16px;
                line-height: 19px;
                color: #FFFFFF;
            }
            button {
                position: absolute;
                height: 30px;
                background: #1D1D1D;
                box-shadow: 2px 2px 4px rgba(0, 0, 0, 0.25);
                border-radius: 20.5px;
            }
            #button-0 {
                width: 84px;
                left: 57px;
                top: 278px;
            }
            #button-1 {
                width: 101px;
                left: 148px;
                top: 278px;
            }
            #button-2 {
                width: 55px;
                left: 256px;
                top: 278px;
            }
            #button-3 {
                width: 84px;
                left: 318px;
                top: 278px;
            }
            #button-4 {
                width: 134px;
                left: 57px;
                top: 317px;
            }
            button span {
                /* position: absolute; */
                width: 61px;
                height: 19px;
                /* left: 69px;
                top: 283px; */
                font-family: 'Inter';
                font-style: normal;
                font-weight: 400;
                font-size: 16px;
                line-height: 19px;
                color: #53C78E;
            }
            #side {
                position: absolute;
                width: 90px;
                height: 422px;
                left: 402px;
                top: -1px;
                opacity: 0.05;

            }
        </style>
    </head>
    <body>
        <div class="namecard">
                <div id="personImg" title="click to flip">
                    <img src={assigns.data[:avatar]} />
                    <!-- <img src="img/person3.jpg" style="height:420px;"> -->
                    <!-- <div class="flip-tip">
                        <span>click here to flip</span>
                    </div> -->
                </div>
            <div class="footer">
              <%= if !is_nil(assigns.data[:ins]) do %>
                  <a href={assigns.data[:ins]}><img src="https://cdn.cdnlogo.com/logos/i/92/instagram.svg" style="left: 26px;"></a>
              <% end %>
              <%= if !is_nil(assigns.data[:facebook]) do %>
                  <a href={assigns.data[:facebook]}><img src="https://cdn.cdnlogo.com/logos/g/55/github.svg" style="left: 46px;"></a>
              <% end %>
              <%= if !is_nil(assigns.data[:twitter]) do %>
                  <a href={assigns.data[:twitter]}><img src="https://cdn.cdnlogo.com/logos/t/96/twitter-icon.svg" style="left: 68px;"></a>
              <% end %>
              <span><%= assigns.data[:email] %></span>
            </div>
            <div class="right">
                <span id="name"><%= assigns.data[:name] %> </span>
                <span id="address"><%= assigns.addr %></span>
                <div class="content">
                    <div id="about_me">
                      <%= @data.about_me %>
                    </div>
                    <div id="abilities">
                      <%= @data.personal_abilities %>
                    </div>
                </div>
                <div class="buttons">
                <%=  Enum.with_index(@data.interesting_fields, fn element, index -> %>
                  <button id={"button-#{index}"}><span><%= element %></span></button>

                <% end) %>
                </div>
                <!-- <div id="side"> -->
                <img id ="side" src="https://tva1.sinaimg.cn/large/e6c9d24egy1h2ohwtgqj3j20500nc0t1.jpg" alt="sideImg">
                <!-- </div> -->
            </div>
        </div>
        <!---->
        <div class="nameCardReverse">
          <div  id="personImgReverse">
            <img src={assigns.data[:avatar]} />
          </div>
          <p id="p-reverse"><%= assigns.data[:name] %> </p>
          <span id="p-reverse-2"><%= assigns.addr %></span>
        </div>

    </body>
    </html>
    """
  end

  def register() do
    KVRouter.put_routes(
      [
        ["/soulcard", "SoulCardRenderLive", "index"]
      ]
    )
  end

  @impl true
  def mount(%{
      "addr" => addr,
      "dao_addr" => dao_addr}, _session, socket) do
    # TODO: check if the addr is created


    # %{user: %{ipfs: ipfs_cid}} = KVHandler.get(addr, "UserManager")
    # %{dao: %{ipfs: dao_ipfs_cid}} = KVHandler.get(dao_addr, "UserManager")

    {:ok, data} = SoulCardRender.get_data("QmTMH123zN2ggGguZkdFDjiDGy3gz89uD9D53ALMLSkis1")
    IO.puts inspect data
    # {:ok, data_dao} = SoulCardRender.get_data(dao_ipfs_cid)

    {
      :ok,
      socket
      |> assign(:data, handle_data(data, :user))
      |> assign(:addr, addr)
      # |> assign(:data_dao, data_dao)
      |> assign(:template_gist_id, @template_gist_id_example)
    }
  end

  def handle_data(data, :user) do
    avatar = Map.get(data, :avatar)
    if is_nil(avatar) or avatar == "" do
      Map.put(data, :avatar, @default_avatar)
    else
      data
    end
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
