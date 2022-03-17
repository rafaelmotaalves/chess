defmodule Chess.Repo.Migrations.AddGameTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      timestamps()
    end

    create table(:game_moves) do
      add :origin_x, :integer
      add :origin_y, :integer
      add :dest_x, :integer
      add :dest_y, :integer
      add :game_id, references(:games)

      timestamps()
    end
  end
end
