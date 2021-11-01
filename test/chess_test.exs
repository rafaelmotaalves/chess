defmodule Chess.ChessTest do
  use ExUnit.Case
  alias Chess.Game

  test "new_game should return a valid board" do
    %{board: board} = Chess.new_game()

    assert length(board) == 64
  end

  test "new_game should start with the white player" do
    %{player: player} = Chess.new_game()

    assert player == :white
  end

  test "move should correctly move to valid position" do
    game = Chess.new_game()

    %{board: board} = Chess.move(game, {1, 0}, {2, 0})

    assert Enum.at(board, 8) == nil
    assert Enum.at(board, 16) == {:black, :pawn}
  end

  test "should do nothing when passed any invalid position" do
    game = Chess.new_game()

    new_game = Chess.move(game, {10, 0}, {2, 0})

    assert game == new_game
  end

  test "should do nothing when passed any invalid dest position" do
    game = Chess.new_game()

    new_game = Chess.move(game, {1, 0}, {-1, 0})

    assert game == new_game
  end

  test "next_player should move player to black when current is white" do
    game = %Game{player: :white}

    %{player: player} = Chess.next_player(game)

    assert player == :black
  end

  test "next_player should move player to white when current is black" do
    game = %Game{player: :black}

    %{player: player} = Chess.next_player(game)

    assert player == :white
  end

  test "valid_move? should return true if the move is valid - pawn - white" do
    assert Chess.new_game |> Chess.valid_move?({6, 0}, {5, 0})
  end

  test "valid_move? should return true if the move is valid - pawn - black" do
    assert Chess.new_game |> Chess.next_player |> Chess.valid_move?({1, 0}, {2, 0})
  end

  test "valid_move? should return false if the move is invalid - pawn - black" do
    game = Chess.new_game |> Chess.next_player()

    refute Chess.valid_move?(game, {1, 0}, {1, 1})
    refute Chess.valid_move?(game, {1, 0}, {2, 1})
    refute Chess.valid_move?(game, {1, 0}, {0, 0})
  end

  test "valid_move? should return false if the move is invalid pawn - white" do
    game = Chess.new_game

    refute Chess.valid_move?(game, {6, 0}, {3, 0})
    refute Chess.valid_move?(game, {6, 0}, {6, 1})
    refute Chess.valid_move?(game, {6, 0}, {5, 1})
    refute Chess.valid_move?(game, {6, 0}, {7, 0})
  end

  test "valid_move? should return true if pawn moves are in the transversal and the move eats another players pieces - white" do
    assert Chess.new_game
    |> Chess.move({1, 0}, {5, 1})
    |> Chess.valid_move?({6, 0}, {5, 1})
  end

  test "valid_move? should return true if pawn moves are in the transversal and the move eats another players pieces - black" do
    assert Chess.new_game
    |> Chess.move({6, 0}, {2, 1})
    |> Chess.next_player()
    |> Chess.valid_move?({1, 0}, {2, 1})
  end

  test "valid_move? should return true if pawn moves two steps over if they are in their initial position" do
    assert Chess.new_game()
    |> Chess.valid_move?({6, 1}, {4, 1})
  end

  test "valid_move? should return false if pawn moves two steps outside the initial position" do
    refute Chess.new_game()
    |> Chess.move({6, 1}, {5, 1})
    |> Chess.valid_move?({5, 1}, {3, 1})
  end

  test "valid_move? should return true if the tower moves in vertical lines" do
    game = Chess.new_game
      |> Chess.move({6, 0}, {6, 1})

    assert Chess.valid_move?(game, {7, 0}, {6, 0})
    assert Chess.valid_move?(game, {7, 0}, {5, 0})
    assert Chess.valid_move?(game, {7, 0}, {3, 0})
    assert Chess.valid_move?(game, {7, 0}, {1, 0})
  end

  test "valid_move? should return true if the tower moves in horizontal lines" do
    game = Chess.new_game
      |> Chess.move({7, 0}, {5, 0})

    assert Chess.valid_move?(game, {5, 0}, {5, 1})
    assert Chess.valid_move?(game, {5, 0}, {5, 7})
  end

  test "valid_move? should return false if the tower moves in tilted lines" do
    game = Chess.new_game
      |> Chess.move({7, 0}, {5, 0})

    refute Chess.valid_move?(game, {5, 0}, {6, 1})
    refute Chess.valid_move?(game, {6, 1}, {7, 0})
  end

  test "valid_move? should return false if tower tries to move over other piece" do
    game = Chess.new_game

    refute Chess.valid_move?(game, {7, 0}, {4, 0})
    refute Chess.valid_move?(game, {7, 7}, {5, 7})
  end

  test "valid_move? should return false if horse tries to move to invalid spaces" do
    game = Chess.new_game

    refute Chess.valid_move?(game, {7, 1}, {5, 1})
    refute Chess.valid_move?(game, {7, 1}, {4, 1})
  end

  test "valid_move? should return true if the horse do a valid move vertical" do
    game = Chess.new_game

    assert Chess.valid_move?(game, {7,1}, {5,0})
    assert Chess.valid_move?(game, {7,1}, {5,2})
  end

  test "valid_move? should return true if the horse do a valid move horizonal" do
    game = Chess.new_game
      |> Chess.move({7, 1}, {4, 2})

    assert Chess.valid_move?(game, {4, 2}, {3, 0})
    assert Chess.valid_move?(game, {4, 2}, {5, 0})
    assert Chess.valid_move?(game, {4, 2}, {5, 4})
    assert Chess.valid_move?(game, {4, 2}, {3, 4})
  end

  test "valid_move? should return false if try to move a piece that is not from the current player" do
    refute Chess.new_game |> Chess.valid_move?({1, 0}, {2, 0})
  end

  test "valid_move? should return false if try to move a piece that doesnt exist" do
    refute Chess.new_game |> Chess.valid_move?({2, 0}, {3, 0})
  end

  test "valid_move? should return false if try to move to a dest that already has a piece for the same team" do
    refute Chess.new_game |> Chess.move({6, 1},{5, 0}) |> Chess.valid_move?({6, 0}, {5, 0})
  end

  test "valid_move? should return false if try to move to invalid position" do
    refute Chess.new_game |> Chess.valid_move?({6, 0}, {-1, 0})
  end

  test "valid_move? should return false if try to move from invalid position" do
    refute Chess.new_game |> Chess.valid_move?({-1, 0}, {1, 0})
  end

  test "valid_move? should return false when try to move to the same position" do
    game = Chess.new_game

    refute Chess.valid_move?(game, {6, 0}, {6, 0})
    refute Chess.valid_move?(game, {7, 0}, {7, 0})
    refute Chess.valid_move?(game, {7, 1}, {7, 1})
  end

  test "valid_move? should return false when try to move bishop horinzontaly or verically" do
    game = Chess.new_game
      |> Chess.move({7, 2}, {4, 1})

    refute Chess.valid_move?(game, {4, 1}, {3, 1})
    refute Chess.valid_move?(game, {4, 1}, {5, 1})
    refute Chess.valid_move?(game, {4, 1}, {4, 2})
    refute Chess.valid_move?(game, {4, 1}, {4,0})
  end

  test "valid_move? should return true when try to move bishop in diagonal" do
    game = Chess.new_game
      |> Chess.move({7, 2}, {4, 1})

    assert Chess.valid_move?(game, {4, 1}, {5, 0})
    assert Chess.valid_move?(game, {4, 1}, {3, 2})
    assert Chess.valid_move?(game, {4, 1}, {1, 4})
  end

  test "valid_move? should return false when try to move bishop over another piece" do
    game = Chess.new_game
      |> Chess.move({7, 2}, {2, 3})

    refute Chess.valid_move?(game, {2, 3}, {0, 5})
    refute Chess.valid_move?(game, {2, 3}, {0, 1})
  end

  test "valid_move? should return false when queen does a invalid move" do
    refute Chess.new_game |> Chess.move({7, 3}, {4, 3})  |> Chess.valid_move?({4, 3}, {2, 2})
  end


  test "valid_move? should return true when queen moves diagonaly" do
    game = Chess.new_game
      |> Chess.move({7,3}, {4,3})

    assert Chess.valid_move?(game, {4, 3}, {5, 4})
    assert Chess.valid_move?(game, {4, 3}, {3, 2})
  end

  test "valid_move? should return true when queen moves horizontaly" do
    game = Chess.new_game
      |> Chess.move({7,3},{4, 3})

    assert Chess.valid_move?(game, {4, 3}, {5, 3})
    assert Chess.valid_move?(game, {4, 3}, {4, 4})
    assert Chess.valid_move?(game, {4, 3}, {1, 3})
  end

  test "valid_move? shoudl return false when queen moves over another piece" do
     game = Chess.new_game
      |> Chess.move({7,3},{4, 3})

    refute Chess.valid_move?(game, {4, 3}, {0, 3})
  end

  test "valid_move? should return false when king moves more than one step" do
    game = Chess.new_game
      |> Chess.move({7, 4}, {4, 4})

    refute Chess.valid_move?(game, {4, 4}, {2, 4})
    refute Chess.valid_move?(game, {4, 4}, {2, 6})
    refute Chess.valid_move?(game, {4, 4}, {2, 3})
    refute game |> Chess.move({4, 4}, {2, 4}) |> Chess.valid_move?({2, 4}, {4, 4})
  end

  test "valid_move? should return true when king moves one tile horizontaly or vertically" do
    game = Chess.new_game
      |> Chess.move({7, 4}, {4, 4})

    assert Chess.valid_move?(game, {4, 4}, {4, 3})
    assert Chess.valid_move?(game, {4, 4}, {3, 4})
    assert Chess.valid_move?(game, {4, 4}, {3, 3})
    assert Chess.valid_move?(game, {4, 4}, {5, 5})
  end

  test "valid_moves should return a list" do
    assert Chess.new_game() |> Chess.valid_moves() |> is_map()
  end

  test "valid_moves should return a set with all the possible moves at game start" do
    moves = Chess.new_game |> Chess.valid_moves()

    assert moves == %{
      {6, 0} => [{5, 0},{4, 0}],
      {6, 1} => [{5, 1},{4, 1}],
      {6, 2} => [{5, 2},{4, 2}],
      {6, 3} => [{5, 3},{4, 3}],
      {6, 4} => [{5, 4},{4, 4}],
      {6, 5} => [{5, 5},{4, 5}],
      {6, 6} => [{5, 6},{4, 6}],
      {6, 7} => [{5, 7},{4, 7}],
      {7, 1} => [{5, 2}, {5, 0}],
      {7, 6} => [{5, 7}, {5, 5}]
  }
  end

  test "check? should return false in the game start" do
    refute Chess.new_game() |> Chess.check?()
  end

  test "check? should return true if one of the other team pieces can move into the current player king" do
    assert Chess.new_game()
      |> Chess.move({6, 5}, {4, 5})
      |> Chess.move({0, 3}, {4, 7})
      |> Chess.check?()
  end
end
