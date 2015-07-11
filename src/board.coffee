###
  game/board - contains functions for dealing with the Sudoku board.
  The board is represented as a flat array of 81 strings.
###

_ = require 'lodash'

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

peers = generatePeers()
units = generateUnits()

assign = (board, index, num) ->
  if not num in board[index] then return false
  board = _.clone board
  board[index] = num
  learnedPeers = []
  for peerIndex in peers[index]
    if num in board[peerIndex]
      newPeer = board[peerIndex].replace(num, '')
      if newPeer.length is 0 then return false
      board[peerIndex] = newPeer
      if newPeer.length is 1 then learnedPeers.push(peerIndex)
  for peerIndex in learnedPeers
    if board[peerIndex].length is 1
      board = assign(board, peerIndex, board[peerIndex])
      if not board then return board
  board

# Returns [numberOfDigitsCleared, newBoard]
clearSquares = (board, numToClear) ->
  for cleared in [0..numToClear-1]
    # Try to find a digit that we can take out without making it unsolvable.
    found = false
    for index in _.shuffle(i for v, i in board when v.length == 1)
      testBoard = _.clone(board)
      testBoard[index] = "" # clear out the digit
      solved = solve(testBoard)
      if solved and not _.any(solved, (n) -> n.length > 1)
        found = true
        board[index] = ""
        break
    if not found then return [cleared, board] # If we can't find any more, then we hit a wall.
  [numToClear, board]


# TODO - optimize this?
# generateBoard does not backtrack beyond 1 step -- if it can't move forward it just quits.
# Because it's very fast, and it will quit as soon as ti makes an invalid step,
# we can get around this by just running it again and again until it works.
# (see generateNew() for an example of that)
generateBoard = (board) ->
  if not _.any(board, (n) -> n.length > 1) then return board
  for index in _.shuffle([0..80])
    value = board[index]
    if value.length <= 1 then continue
    for num in value
      newBoard = assign(board, index, num)
      if newBoard then return generateBoard(newBoard)
  false

solve = (board) ->
  internalBoard = ("123456789" for [0..80])
  for sq, i in board
    if sq.length is 1
      internalBoard = assign(internalBoard, i, sq)
      if not internalBoard
        return false
  internalBoard

generateNew: (min, max) ->
  if min > max then throw Error 'min > max when calling generateNew()'
  # Step 1: Generate a completely solved game board
  internalBoard = ("123456789" for [0..80])
  newBoard = generateBoard(internalBoard) until newBoard # sometimes we generate 30+ boards until one is valid
  # Step 2: Clear out digits, while maintaining solvability
  maxToClear = 81 - min
  minToClear = 81 - max
  tries = 100
  numCleared = 0
  while numCleared < minToClear and tries--
    tmp = clearSquares(newBoard, maxToClear)
    if tmp[0] > numCleared then [numCleared, clearedBoard] = tmp
  clearedBoard

isInvalid: (board, i) ->
  if board[i].length isnt 1 then return false
  _.any peers[i], (j) => j isnt i and board[j] is board[i]

module.exports =
  sameRow: sameRow
  sameCol: sameCol
  sameSquare: sameSquare
  sameUnit: sameUnit
  units: units
  peers: peers
  solve: solve
  generateNew: generateNew
  isInvalid: isInvalid