defmodule Scheherazade.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ~w(html)
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ~w(json)
    plug :fetch_session
  end

  scope "/api", Scheherazade do
    pipe_through :api

    resources "/users", UserController
  end

  scope "/", Scheherazade do
    pipe_through :browser # Use the default browser stack

    get "*anything", PageController, :index
  end

end
