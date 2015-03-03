defmodule Scheherazade.User.Query do
  import Ecto.Query
  alias Comeonin.Pbkdf2, as: Crypt
  alias Scheherazade.Repo
  alias Scheherazade.User

  defmacrop with_transaction!([do: body]) do
    quote do
      {:ok, v} = Repo.transaction(fn -> unquote(body) end)
      v
    end
  end

  def create(params) do
    with_transaction! do
      Repo.insert User.changeset!(%User{}, params)
    end
  end

  def update(email, params) do
    with_transaction! do
      Repo.update User.changeset!(find_one!(email), params)
    end
  end

  def delete(email) do
    with_transaction! do
      Repo.delete find_one!(email)
    end
  end

  def find_one(email), do: Repo.one find_one_query(email)
  def find_one!(email), do: Repo.one! find_one_query(email)
  def find_one_query(email), do: (from u in User, where: u.email == ^email)

  def find_all(), do: Repo.all User

  def check_password(email, password) do
    case find_one email do
      user = %User{password: hashed} ->
        Crypt.checkpw(password, hashed) && user
      nil ->
        # NOTE: The dummy check protects against detection of users by
        #       checking timings. This function always returns false.
        Crypt.dummy_checkpw
    end
  end

end
