defmodule Scheherazade.User.Query do
  import Ecto.Query
  alias Comeonin.Pbkdf2, as: Crypt
  alias Scheherazade.Repo, as: Repo
  alias Scheherazade.User, as: User

  defmacrop txn!([do: body]) do
    quote do
      {:ok, v} = Repo.transaction(fn -> unquote(body) end)
      v
    end
  end

  def create(%{"email" => email,
               "password" => rawPass,
               "display_name" => displayName}) do
    txn! do
      case find_one email do
        nil ->
          %User{email: email,
                password: Crypt.hashpwsalt(rawPass),
                display_name: displayName}
          |> Repo.insert
        _ ->
          throw {:error, :already_exists}
      end
    end
  end

  def update(params = %{"id" => email}) do
    txn! do
      case find_one email do
        nil ->
          throw {:error, :not_found}
        user ->
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
    txn! do
      case find_one(email) do
        nil ->
          throw {:error, :not_found}
        user ->
          Repo.delete(user)
      end
    end
  end

  def find_one(email) do
    Repo.one from u in User, where: u.email == ^email
  end
  def find_one(email, password) do
    user = find_one email
    if user && Crypt.checkpw(password, user.password) do
      if Crypt.checkpw(password, user.password) do
        user
      end
    else
      # NOTE: The dummy check protects against detection of users by
      #       checking timings.
      Crypt.dummy_checkpw
      nil
    end
  end

  def find_all() do
    Repo.all User
  end
end
