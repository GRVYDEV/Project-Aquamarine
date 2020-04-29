defmodule ChatWeb.Plugs.AuthUser do
  import Plug.Conn
  import Phoenix.Controller

  alias ChatWeb.Router.Helpers, as: Routes

  def init(_) do

  end

  def call(conn, _params) do
    if conn.assigns.signed_in? do
      conn
    else
      conn
      |> put_flash(:error, "Must Be Signed In")
      |> redirect(to: Routes.session_path(conn, :new))
      |> halt()
    end
  end
end
