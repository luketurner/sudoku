###
  game/board - contains functions for dealing with the Sudoku board.
  The board is represented as a flat array of 81 strings.
###

_     = require 'lodash'

sameRow = (i, j) -> i // 9 is j // 9
sameCol = (i, j) -> i % 9 == j % 9
sameSquare = (i, j) ->
  (i // 3) % 3 == (j // 3) % 3 and
    ((0 <= i < 27 and 0 <= j < 27) or
      (27 <= i < 54 and 27 <= j < 54) or
      (54 <= i < 81 and 54 <= j < 81))
sameUnit = (i, j) -> sameRow(i, j) or sameCol(i, j) or sameSquare(i, j)

generatePeers = () -> j for j in [0..80] when sameUnit(i, j) and i isnt j for i in [0..80]
generateUnits = () ->
  units = ([[],[],[]] for i in [0..80])
  for i in [0..80]
    for j in [0..80]
      if sameRow(i, j)
        units[i][0].push(j)
      if sameCol(i, j)
        units[i][1].push(j)
      if sameSquare(i, j)
        units[i][2].push(j)
  units

assign = (board, index, num) ->
  if not num in board[index] then return false
  board[index] = num
  for peerIndex in Board::peers[index]
    if num in board[peerIndex]
      newPeer = board[peerIndex].replace(num, '')
      if newPeer.length is 0 then return false
      board[peerIndex] = newPeer
      if newPeer.length is 1 then assign(board, peerIndex, newPeer)
  board

class Board extends Array
  sameRow: sameRow
  sameCol: sameCol
  sameSquare: sameSquare
  sameUnit: sameUnit
  units: generateUnits()
  peers: generatePeers()
  constructor: (oldBoard) ->
    @reset()
    if oldBoard
      @[i] = v for v, i in oldBoard

  reset: () ->
    @[i] = "" for x,i in this
    @pop() while @length > 81
    @push "" while @length < 81
    this

  solve: () ->
    internalBoard = ("123456789" for [0..80])
    for sq, i in this
      if sq.length is 1
        if not assign(internalBoard, i, sq)
          throw new Error "makeInternalCopy called on board in invalid state"
    @[i] = v for v, i in internalBoard
    this

  isInvalid: (i) ->
    if @[i].length isnt 1 then return false
    _.any @peers[i], (j) => j isnt i and @[j] is @[i]

  # Convert these to new form
  #moveInvalid: (i, inum) -> _.some this, (jnum, j) -> (inum is jnum) and (i isnt j) and sameUnit(i, j)
  #moveValid: (i, inum) -> not @moveInvalid i, inum

module.exports = Board