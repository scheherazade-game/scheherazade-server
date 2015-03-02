defmodule Scheherazade.UserController do
  use Phoenix.Controller
  alias Scheherazade.User.Query, as: UserQ

  plug :action

  def index(conn, _params) do
    ok(conn, (for u <- UserQ.find_all(), do: scrub u))
  end

  def show(conn, %{"id" => email}) do
    case UserQ.find_one email do
      nil ->
        not_found conn
      user ->
        ok(conn, scrub user)
    end
  end

  def create(conn, params = %{"email" => _,
                              "password" => _,
                              "display_name" => _}) do
    try do
      ok(conn, UserQ.create(params) |> scrub)
    catch
      {:error, :already_exists} ->
        conn
        |> put_status(:conflict)
        |> json %{error: "A user with that email already exists"}
    end
  end
  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json %{error: "Invalid user"}
  end

  def delete(conn, %{"id" => email}) do
    try do
      ok(conn, UserQ.delete(email) |> scrub)
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

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> json %{error: "No such user exists"}
  end

end
