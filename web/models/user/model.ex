defmodule Scheherazade.User do
  use Ecto.Model
  alias Comeonin.Pbkdf2, as: Crypt

  schema "user" do
    field :email, :string
    field :display_name, :string
    field :full_name, :string
    field :password, :string
    timestamps
  end

  def changeset(user, params \\ nil) do
    params
    |> cast(user, ~w(email), ~w(display_name full_name password))
    |> update_change(:email, &String.downcase/1)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, 3..254)
    |> validate_unique(:email, on: Scheherazade.Repo)
    |> validate_length(:password, 8..254)
    |> update_change(:password, &Crypt.hashpwsalt/1)
    |> validate_exclusion(:password, [Map.get(user, :password)])
    |> validate_length(:display_name, 2..254)
    |> validate_length(:full_name, 2..254)
  end

  def changeset!(user, params \\ nil) do
    cs = changeset user, params
    if cs.valid? do
      cs
    else
      throw {:errors,
             for e <- cs.errors do
               case e do
                 {field, {type, info}} ->
                   %{field: field, type: type, info: info}
                 {field, type} ->
                   %{field: field, type: type, info: []}
               end
             end}
    end
  end

end
