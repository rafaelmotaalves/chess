defmodule Chess.Model.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    has_many :moves, Chess.Model.Move
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end

end
