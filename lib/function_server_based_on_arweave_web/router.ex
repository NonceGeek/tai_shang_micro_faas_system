defmodule FunctionServerBasedOnArweaveWeb.Router do
  alias Components.KVHandler.KVRouter
  use FunctionServerBasedOnArweaveWeb, :router
  use Pow.Phoenix.Router

  dynamic_scopes =
    KVRouter.get_routes()

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FunctionServerBasedOnArweaveWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_empty do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FunctionServerBasedOnArweaveWeb.LayoutView, :empty}
    plug :protect_from_forgery
    plug CORSPlug, origin: [~r/.*/]
    # plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, origin: [~r/.*/]
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :admin do
    plug FunctionServerBasedOnArweaveWeb.EnsureRolePlug, :admin
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end
  scope "/", FunctionServerBasedOnArweaveWeb do
    pipe_through :browser
    live "/", CodeLoaderLive.Index, :index
  end

  scope "/dynamic/", CodesOnChain do
    pipe_through :browser_empty
    for [uri, controller, action] <- dynamic_scopes do
      live uri, String.to_atom(controller), String.to_existing_atom(action)
    end
  end

  scope "/", FunctionServerBasedOnArweaveWeb do
    pipe_through :browser_empty
    live "/page",  PageLive, :index
    live "/namecard", NameCardLive, :index
  end

  scope "/", FunctionServerBasedOnArweaveWeb do
    pipe_through [:browser,:protected, :admin]
    live "/add_func", FuncAdderLive.Index, :index
    live "/remove_code", CodeRemoveLive.Index, :index
  end

  scope "/api/v1", FunctionServerBasedOnArweaveWeb do
    pipe_through :api

    get "/get_codes",  FunctionRunnerController, :get_codes
    get "/get_code",  FunctionRunnerController, :get_code
    post "/run", FunctionRunnerController, :run
  end

  # Other scopes may use custom stacks.
  # scope "/api", FunctionServerBasedOnArweaveWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through :browser
  #     live_dashboard "/dashboard", metrics: FunctionServerBasedOnArweaveWeb.Telemetry
  #   end
  # end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
