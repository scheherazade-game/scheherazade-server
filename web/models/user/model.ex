defmodule Scheherazade.User do
  use Ecto.Model

  schema "user" do
    field :email, :string
    field :display_name, :string
    field :full_name, :string
    field :password, :string
    timestamps
  end
end
