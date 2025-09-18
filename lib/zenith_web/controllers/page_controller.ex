defmodule ZenithWeb.PageController do
  use ZenithWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
