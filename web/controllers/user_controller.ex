defmodule Scheherazade.UserController do
  use Phoenix.Controller
  alias Scheherazade.User
  alias Scheherazade.User.Query

  plug :action

  def index(conn, _params) do
    ok(conn, (for u <- Query.find_all(), do: scrub u))
  end

  def show(conn, %{"id" => email}) do
    try do
      ok(conn, Query.find_one!(email) |> scrub)
    rescue
      Ecto.NoResultsError ->
        not_found conn
    end
  end

  def create(conn, params) do
    try do
      ok(conn, Query.create(params) |> scrub)
    catch
      {:errors, errors} ->
        error conn, :unprocessable_entity, errors
    end
  end

  def update(conn, params = %{"id" => email}) do
    try do
      ok(conn, Query.update(email, params) |> scrub)
    catch
      {:errors, errors} ->
        error conn, :unprocessable_entity, errors
    end
  end

  def delete(conn, %{"id" => email}) do
    try do
      ok(conn, Query.delete(email) |> scrub)
    rescue
      Ecto.NoResultsError ->
        not_found conn
    end
  end

  #
  # Util
  #
  defp scrub(user) do
    user |> Map.take([
      :email, :display_name, :full_name
    ])
  end

  defp ok(conn, data) do
    conn
    |> put_status(:ok)
    |> json %{data: data}
  end

  defp not_found(conn) do
    error conn, :not_found, []
  end

  defp error(conn, status, errors) do
    conn
    |> put_status(status)
    |> json %{errors: errors}
  end

end
