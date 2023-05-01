defmodule TaiShangMicroFaasSystemWeb.PageController do
  use TaiShangMicroFaasSystemWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
