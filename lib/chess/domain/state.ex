defmodule Chess.Domain.Game do
  defstruct board: [
    {:black, :tower},{:black, :horse},{:black, :bishop},{:black, :queen},{:black,:king}, {:black,:bishop},{:black, :horse},{:black, :tower},
    {:black, :pawn},{:black, :pawn},{:black, :pawn},{:black, :pawn},{:black, :pawn},{:black, :pawn},{:black, :pawn},{:black, :pawn},
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil,
    nil,nil,nil,nil,nil,nil,nil,nil,
    {:white, :pawn},{:white, :pawn},{:white, :pawn},{:white, :pawn},{:white, :pawn},{:white, :pawn},{:white, :pawn},{:white, :pawn},
    {:white, :tower},{:white, :horse},{:white, :bishop},{:white, :queen},{:white,:king}, {:white,:bishop},{:white, :horse},{:white, :tower},
  ], player: :white
end
