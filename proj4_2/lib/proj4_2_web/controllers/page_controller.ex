defmodule Proj42Web.PageController do
  use Proj42Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, params) do
    #broadcast logout info
    user_id = params["user_id"]
    Proj42Web.Endpoint.broadcast("user_socket:" <> user_id, "disconnect", %{})
    render(conn, "login.html")
  end

  def tweet(conn, params) do
    username = Map.get(params, "username")
    conn
    |> assign(:username, username)
    |> render("tweet.html")
  end
end
