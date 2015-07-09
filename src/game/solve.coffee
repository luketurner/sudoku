_     = require 'lodash'
Board = require './board.coffee'

# Using Norvig's sudoku solver, adapted for JS

eliminate = (board, index, num) ->
  return board unless num in board[index] # num wasn't an option to begin with
  board[index] = board[index].replace(num, '')
  return false if board[index].length is 0 # board is in an invalid state
  if board[index].length is 1 # Exactly one value can go here -- propagate elimination
    return false unless _.all(Board::peers[index], (nextIndex) -> eliminate(board, nextIndex, board[index]))
  for unit in Board::units[index]
    placesForNum = (i for i in unit when (num in board[i]))
    return false if placesForNum.length is 0 # no place for this number means we have invalid state
    if placesForNum.length is 1 # exactly one place for this number -- we should assign it.
      return false unless assign(board, placesForNum[0], num)

assign = (board, index, num) ->
  otherChoices = board[index].replace(num, '')
  if _.all(otherChoices, (n) -> eliminate(board, index, n)) then board else false

solve = (board) ->
  if not board then return false # no solution
  if not _.some(board, (n) -> n.length > 1) then return board # solved!
  num = _.min(board, (n) -> if n.length is 1 then Infinity else n.length)
  index = _.findIndex(board, num)
  _.find(solve(assign(_.clone(board), index, n)) for n in board[index], (x) -> x isnt false)

module.exports = (board) ->
  console.log "before: ", board
  board.toInternal() unless board.isInternal
  boardArray = board.concat [] # Convert to a simple array (in case arrays are optimized)
  solvedArray = solve(boardArray)
  solvedBoard = new Board solvedArray # create a new board from the solution
  console.log "after: ", solvedBoard
  solvedBoard
