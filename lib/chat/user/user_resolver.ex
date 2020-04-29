defmodule Chat.User.UserResolver do
  alias Chat.Accounts
  alias Chat.Accounts.User

  def all(_args, _info) do
    {:ok, Accounts.list_users()}
  end

  def create(params, _info) do
    case Accounts.create_user(params) do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end
end
