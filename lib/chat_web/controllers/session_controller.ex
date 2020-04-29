defmodule ChatWeb.SessionController do
  use ChatWeb, :controller

  alias Chat.Accounts
  def new(conn, _) do
    render(conn, "new.html")
  end

  def index(conn, _) do

    render(conn, "index.html", edit: nil)
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Accounts.sign_in(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> put_flash(:info, "Sign In Successful")
        |> redirect(to: Routes.room_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid Email or Password")
        |> render("new.html")
    end

  end

  def edit(conn, _params) do

    user = Accounts.current_user(conn)
    changeset = Accounts.change_user(user)
    render(conn, "index.html", changeset: changeset, edit: 1)
  end

  def update(conn, %{"user" => user_params}) do
    inspect(conn)
    user = Accounts.current_user(conn)

    case Accounts.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User Updated!")
        |> redirect(to: Routes.session_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", edit: 1, changeset: changeset)
    end
  end
  def delete(conn, _params) do

    conn
    |> Accounts.sign_out(conn)
    |> redirect(to: Routes.session_path(conn, :index))
  end
end
