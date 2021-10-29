defmodule Chess do
  @moduledoc """
  Chess keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Chess.Game

  def new_game() do
    %Game{}
  end

  def next_player(game) do
    %Game{game | player: get_next_player(game)}
  end

  def get_next_player(%{player: player}) do
    case player do
      :black -> :white
      :white -> :black
    end
  end

  def valid_move?(%{player: current_player, board: _board} = game, origin, dest) do
    base_conditions =
      case value_at(game, origin) do
        {player, _type} ->
          case value_at(game, dest) do
            nil -> convert_position(dest)
            {dest_player, _type} -> dest_player != current_player
          end && current_player == player
        nil ->
          false
      end

    cond do
      base_conditions ->
        {_player, type} = value_at(game, origin)

        case type do
          :pawn -> valid_move_pawn?(game, origin, dest)
          :tower -> valid_move_tower?(game, origin, dest)
          _ -> true
        end
      true ->
        false
    end
  end

  defp valid_move_tower?(game, {x, y}, {z, w}) do
    cond do
      x == z -> Enum.all? y..w, fn(a) -> a == y || a == w || value_at(game, {x, a}) == nil end
      y == w -> Enum.all? x..z, fn(a) -> a == x || a == z || value_at(game, {a, y}) == nil end
      true -> false
    end
  end

  defp valid_move_pawn?(game, {x, y} = origin, {z, w}) do
    {player, _type} = value_at(game,  origin)

    direction = case player do
      :black -> 1
      :white -> -1
    end

    new_x = x + direction
    (new_x == z) && !!cond do
      y == w -> true
      y - 1 == w -> value_at(game, {new_x, y - 1})
      y + 1 == w -> value_at(game, {new_x, y + 1})
      true -> false
    end
  end

  def value_at(%{board: board}, pos) do
    pos = convert_position(pos)

    pos && Enum.at(board, pos)
  end

  def move(%{board: board} = game, pos, dest) do
    pos_index = convert_position(pos)
    dest_index = convert_position(dest)

    cond do
      val = pos_index && dest_index && Enum.at(board, pos_index) ->
        new_board =
          board
          |> List.replace_at(dest_index, val)
          |> List.replace_at(pos_index, nil)

        %Game{game | board: new_board}

      true ->
        game
    end
  end

  defp convert_position({x, y}) do
    cond do
      x >= 0 && x < 8 && y >= 0 && y <= 8 -> x * 8 + y
      true -> nil
    end
  end
end
