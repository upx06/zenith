defmodule ZenithWeb.PageController do
  use ZenithWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

  def react_app(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, Application.app_dir(:zenith, "priv/static/index.html"))
  end

end
