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

  def create(%{"email" => email,
               "password" => rawPass,
               "display_name" => displayName}) do
    with_transaction! do
      case find_one email do
        nil ->
          %User{email: email,
                password: Crypt.hashpwsalt(rawPass),
                display_name: displayName}
          |> Repo.insert
        %User{} ->
          throw {:error, :already_exists}
      end
    end
  end

  def update(params = %{"id" => email}) do
    with_transaction! do
      case find_one email do
        nil ->
          throw {:error, :not_found}
        user = %User{} ->
          %{user |
            email: Map.get(params, "email", user.email),
            password: if Map.get(params, "password") do
                        Crypt.hashpwsalt(params.password)
                      else
                        user.password
                      end,
            display_name: Map.get(params, "display_name", user.display_name)}
          |> Repo.insert
      end
    end
  end

  def delete(email) do
    with_transaction! do
      case find_one(email) do
        nil ->
          throw {:error, :not_found}
        user = %User{} ->
          Repo.delete(user)
      end
    end
  end

  def find_one(email) do
    Repo.one from u in User, where: u.email == ^email
  end
  def find_one(email, password) do
    case find_one email do
      nil ->
        # NOTE: The dummy check protects against detection of users by
        #       checking timings.
        Crypt.dummy_checkpw
        nil
      user = %User{password: hashed} ->
        if Crypt.checkpw(password, hashed) do
          user
        end
    end
  end

  def find_all() do
    Repo.all User
  end
end
