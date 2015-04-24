_ = require 'lodash'

basePuzzle = "534678912
              672195348
              198342567
              859761423
              426853791
              713924856
              961537284
              287419635
              345286179".replace(/[^\d]/g, "").split("").map (x) -> parseInt(x, 10)

swap = (a, b) -> (x) -> if x == a then b else if x == b then a else x

scramble = (puzzle) ->
  puzzle = _.chain puzzle
  for i in [1..10]
    puzzle = puzzle.map swap _.random(1, 9), _.random(1, 9)
  puzzle.map swap(1, 2)
  puzzle.value()

invalid = (board, i) ->
  me = board[i]
  _.some board, (you, j) ->
    me == you and # same number
      i != j and # not the same space
      (i % 9 == j % 9 or # Same column
        i // 9 == j // 9 or # Same row
        ((i // 3) % 3 == (j // 3) % 3 and # Same square
          (( 0 <= i < 27 and  0 <= j < 27) or
            (27 <= i < 54 and 27 <= j < 54) or
            (54 <= i < 81 and 54 <= j < 81))))


solve = (board) ->

generate = () ->
  puzzle = scramble(basePuzzle)
  #console.log i for i in [0..80] when invalid puzzle, i
  # Converts the puzzle into the same nested format used elsewhere,
  # so you can access (x,y) at puzzle[x][y] instead of puzzle[x+y*9]
  puzzle[x+y*9] for y in [0..8] for x in [0..8]

module.exports = generate
