defmodule ChatWeb.Router do
  use ChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ChatWeb.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug ChatWeb.Plug.Context
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/", ChatWeb do
    pipe_through :browser

    get "/", SessionController, :index
    resources("/rooms", RoomController)
    resources("/sessions", SessionController, only: [:new, :create, :index, :edit, :update])
    resources("/registration", RegistrationController, only: [:new, :create])
    delete "/sign_out", SessionController, :delete

  end

  scope "/api" do
    pipe_through :graphql
    #forward "/", Absinthe.Plug, schema: ChatWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: ChatWeb.Schema
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatWeb do
  #   pipe_through :api
  # end
end
