defmodule ChatWeb.Schema do
  use Absinthe.Schema
  alias Chat.Room.RoomResolver
  alias Chat.User.UserResolver
  import_types ChatWeb.Schema.Types

  query do
    field :rooms, list_of(:room) do
      resolve &RoomResolver.all/2
    end

    field :users, list_of(:user) do
      resolve &UserResolver.all/2
    end
  end

  mutation do
    field :create_room, type: :room do
      arg :name, non_null(:string)
      arg :topic, :string
      arg :description, :string
      resolve &RoomResolver.create/2
    end

    field :create_user, type: :user do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :password_confirmation, non_null(:string)

      resolve &UserResolver.create/2
    end

  end

end
