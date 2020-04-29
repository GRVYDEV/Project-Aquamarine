defmodule ChatWeb.RoomController do
  use ChatWeb, :controller

  alias Chat.Talk.Room
 
  alias Chat.Talk

  plug ChatWeb.Plugs.AuthUser when action in [:new, :create, :show, :edit, :update, :delete, :index]
  plug :authorize_user when action in [:edit, :update, :delete]
  def index(conn, _params) do
    rooms = Talk.list_rooms()
    render(conn, "index.html", rooms: rooms, activeroom: nil, edit: nil, create: nil)
  end

  def new(conn, _params) do
    rooms = Talk.list_rooms()
    changeset = Room.changeset(%Room{}, %{})
    render(conn, "index.html", changeset: changeset, rooms: rooms, create: 1, edit: nil, activeroom: nil)
  end

  def create(conn, %{"room" => room_params}) do
    rooms = Talk.list_rooms()
    case Talk.create_room(conn.assigns.current_user, room_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Room Created!")
        |> redirect(to: Routes.room_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", changeset: changeset, rooms: rooms, create: 1, edit: nil, activeroom: nil)

    end
  end
  def show(conn, %{"id" => id}) do
    activeroom = Talk.get_room!(id)
    rooms = Talk.list_rooms()
    render(conn, "index.html", rooms: rooms, activeroom: activeroom, edit: nil)
  end

  def edit(conn, %{"id" => id}) do
    room = Talk.get_room!(id)
    changeset = Talk.change_room(room)
    rooms = Talk.list_rooms()
    render(conn, "index.html", rooms: rooms, activeroom: room, edit: 1, changeset: changeset)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Talk.get_room!(id)
    rooms = Talk.list_rooms()
    case Talk.update_room(room, room_params) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room Updated!")
        |> redirect(to: Routes.room_path(conn, :show, id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", rooms: rooms, activeroom: room, edit: 1, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Talk.get_room!(id)
    {:ok, _room} = Talk.delete_room(room)

    conn
    |> put_flash(:info, "Room deleted")
    |> redirect(to: Routes.room_path(conn, :index))
  end

  defp authorize_user(conn, _params) do
    %{params: %{"id" => room_id}} = conn
    room = Talk.get_room!(room_id)

    if conn.assigns.current_user.id == room.user_id do
      conn
    else
      conn
      |> put_flash(:error, "Unauthorized")
      |> redirect(to: Routes.room_path(conn, :show, room_id))
      |> halt()
    end
  end

end
