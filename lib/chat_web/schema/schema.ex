defmodule ChatWeb.Schema do
  use Absinthe.Schema
  alias Chat.Room.RoomResolver
  alias Chat.User.UserResolver
  alias Chat.Session.SessionResolver
  import_types ChatWeb.Schema.Types

  query do
    field :rooms, list_of(:room) do
      middleware Chat.Middleware.Auth
      resolve &RoomResolver.all/2
    end

    field :users, list_of(:user) do
      middleware Chat.Middleware.Auth
      resolve &UserResolver.all/2
    end

    field :user, :user do
      arg :id, non_null(:id)
      middleware Chat.Middleware.Auth
      resolve &UserResolver.find_user/3
    end
  end

  mutation do
    field :create_room, type: :room do
      arg :name, non_null(:string)
      arg :topic, :string
      arg :description, :string
      middleware Chat.Middleware.Auth
      resolve &RoomResolver.create/2
    end

    field :create_user, type: :session do
      arg :username, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :password_confirmation, non_null(:string)

      resolve &UserResolver.create/2
    end

    field :sign_in, type: :session do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &SessionResolver.new/2
    end
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Chat.Middleware.ErrorHelper]
  end
  # if it's any other object keep things as is
  def middleware(middleware, _field, _object), do: middleware

end
