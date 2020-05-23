defmodule Chat.Session.SessionResolver do
  alias Chat.Accounts

  def new(%{:email => email, :password => password}, _info) do
    with {:ok, user} <- Accounts.sign_in(email, password),
         {:ok, jwt, _} <- Chat.Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt}}
    else
      _ -> {:error, "Issue with email or password"}
    end
  end
end
