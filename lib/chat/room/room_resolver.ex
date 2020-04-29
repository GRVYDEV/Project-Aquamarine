defmodule Chat.Room.RoomResolver do
  alias Chat.Talk
  alias Chat.Talk.Room
  alias Chat.Accounts

  def all(_args, _info) do
    {:ok, Talk.list_rooms()}
  end

  def create(args, _info) do
    IO.puts(inspect(args))
  end
end
