defmodule Hubiot.Repo.Migrations.CreateDonnees do
  use Ecto.Migration

  def change do
    create table(:donnees) do
      add :value, :integer
      add :location, :string

      timestamps()
    end

  end
end
