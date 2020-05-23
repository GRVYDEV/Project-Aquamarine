defmodule ChatWeb.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Chat.Repo

  object :user do
    field(:id, :id)
    field(:username, :string)
    field(:email, :string)
    field(:password_hash, :string)
    field(:rooms, list_of(:room), resolve: assoc(:rooms))
    field(:messages, list_of(:message), resolve: assoc(:messages))
  end

  object :session do
    field(:token, :string)
  end

  object :room do
    field(:id, :id)
    field(:description, :string)
    field(:name, :string)
    field(:topic, :string)
    field(:user, :user, resolve: assoc(:users))
    field(:messages, list_of(:message), resolve: assoc(:messages))
  end

  object :message do
    field(:body, :string)
    field(:user, :user, resolve: assoc(:user))
    field(:room, :room, resolve: assoc(:room))
  end
end
