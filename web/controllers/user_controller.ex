defmodule Scheherazade.UserController do
  use Phoenix.Controller
  alias Scheherazade.User
  alias Scheherazade.User.Query

  plug :action

  def index(conn, _params) do
    ok(conn, (for u <- Query.find_all(), do: scrub u))
  end

  def show(conn, %{"id" => email}) do
    case Query.find_one email do
      nil ->
        not_found conn
      user = %User{} ->
        ok(conn, scrub user)
    end
  end

  def create(conn, params = %{"email" => _,
                              "password" => _,
                              "display_name" => _}) do
    try do
      ok(conn, Query.create(params) |> scrub)
    catch
      {:error, :already_exists} ->
        error conn, :conflict, "A user with that email already exists"
    end
  end
  def create(conn, _params) do
    error conn, :unprocessable_entity, "Invalid user"
  end

  def delete(conn, %{"id" => email}) do
    try do
      ok(conn, Query.delete(email) |> scrub)
    catch
      {:error, :not_found} ->
        not_found conn
    end
  end

  #
  # Util
  #

  defp scrub(user) do
    user |> Map.take([
      :id, :email, :display_name, :full_name
    ])
  end

  defp ok(conn, data) do
    conn
    |> put_status(:ok)
    |> json %{data: data}
  end

  defp error(conn, status, msg) do
    conn
    |> put_status(status)
    |> json %{error: msg}
  end

  defp not_found(conn) do
    error conn, :not_found, "No such user exists"
  end

end
