defmodule Scheherazade.Repo.Migrations.UsersTable do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :text
      add :full_name, :text
      add :display_name, :text
      add :password, :text
      timestamps
    end
    create index(:user, [:email], unique: true)
  end
end
