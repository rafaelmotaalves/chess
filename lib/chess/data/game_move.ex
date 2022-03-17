defmodule Chess.Data.GameMove do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_moves" do
    belongs_to :game, Chess.Data.Game
    field :origin_x, :integer
    field :origin_y, :integer
    field :dest_x, :integer
    field :dest_y, :integer
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:origin_x, :origin_y, :dest_x, :dest_y])
    |> validate_required([:origin_x, :origin_y, :dest_x, :dest_y])
  end

end
