_     = require 'lodash'
State = require './state.coffee'
Board = require '../board.coffee'

history = []
currentIndex = -1
History = module.exports = {}

load = (index) ->
  currentIndex = index
  state = history[index]
  State.board = _.clone state.board
  State.lockedSquares = _.clone state.lockedSquares
  State.selected = state.selected

History.service = (next) ->
  (data) ->
    next(data)
    if data.historical
      if currentIndex + 1 < history.length then history = history.slice(0, currentIndex + 1)
      history.push
        selected: State.selected
        board: _.clone State.board
        lockedSquares: _.clone State.lockedSquares
      currentIndex = history.length - 1

History.undo = -> if currentIndex > 0 then load(currentIndex - 1)
History.redo = -> if history.length > currentIndex + 1 then load(currentIndex + 1)
History.undoAll = -> if currentIndex > 0 then load(0)
History.redoAll = -> if history.length > currentIndex + 1 then load(history.length - 1)