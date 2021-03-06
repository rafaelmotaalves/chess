defmodule Chess.Domain.Chess do
  alias Chess.Domain.Game

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

  def valid_moves(game) do
    moves =
      for x <- 0..7, y <- 0..7, z <- 0..7, w <- 0..7, valid_move?(game, {x, y}, {z, w}) do
        {{x, y}, {z, w}}
      end

    Enum.reduce(moves, %{}, fn {origin, dest}, acc ->
      {_, new} =
        Map.get_and_update(acc, origin, fn l ->
          new_l =
            case l do
              nil -> [dest]
              l -> [dest | l]
            end

          {l, new_l}
        end)

      new
    end)
  end

  def check?(%{player: current_player} = game) do
    next_player_game = next_player(game)
    moves = valid_moves(next_player_game)

    Enum.any?(moves, fn {_k, v} ->
      Enum.any?(v, fn x ->
        case value_at(game, x) do
          {player, type} -> player == current_player && type == :king
          nil -> false
        end
      end)
    end)
  end

  def valid_move?(%{player: current_player} = game, origin, dest) do
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
          :horse -> valid_move_horse?(game, origin, dest)
          :bishop -> valid_move_bishop?(game, origin, dest)
          :queen -> valid_move_queen?(game, origin, dest)
          :king -> valid_move_king?(game, origin, dest)
          _ -> true
        end

      true ->
        false
    end
  end

  defp valid_move_king?(_game, {x, y}, {z, w}) do
    dx = abs(x - z)
    dy = abs(y - w)

    dx <= 1 && dy <= 1
  end

  defp valid_move_queen?(game, origin, dest) do
    valid_move_bishop?(game, origin, dest) || valid_move_tower?(game, origin, dest)
  end

  defp valid_move_bishop?(game, {x, y}, {z, w}) do
    px = z - x
    py = w - y

    cond do
      abs(px) == abs(py) ->
        {mx, my} = {if(px < 0, do: -1, else: 1), if(py < 0, do: -1, else: 1)}

        apx = abs(px)

        apx == 1 ||
          Enum.all?(1..(apx - 1), fn a ->
            xa = x + a * mx
            ya = y + a * my

            value_at(game, {xa, ya}) == nil
          end)

      true ->
        false
    end
  end

  defp valid_move_horse?(_game, {x, y}, {z, w}) do
    ((x + 2 == z || x - 2 == z) && (y + 1 == w || y - 1 == w)) ||
      ((y + 2 == w || y - 2 == w) && (x + 1 == z || x - 1 == z))
  end

  defp valid_move_tower?(game, {x, y}, {z, w}) do
    cond do
      x == z -> Enum.all?(y..w, fn a -> a == y || a == w || value_at(game, {x, a}) == nil end)
      y == w -> Enum.all?(x..z, fn a -> a == x || a == z || value_at(game, {a, y}) == nil end)
      true -> false
    end
  end

  defp valid_move_pawn?(game, {x, y} = origin, {z, w}) do
    {player, _type} = value_at(game, origin)

    {direction, initial_row} =
      case player do
        :black -> {1, 1}
        :white -> {-1, 6}
      end

    new_x = x + direction

    (new_x == z &&
       cond do
         y == w -> true
         y - 1 == w -> value_at(game, {new_x, y - 1})
         y + 1 == w -> value_at(game, {new_x, y + 1})
         true -> false
       end) || (x == initial_row && x + direction * 2 == z && y == w)
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
