State = require './state.coffee'
Board = require '../game/board.coffee'

history = []
History = module.exports = {}


History.service = (next) ->
  (data) ->
    if data.historical
      history.push
        selected: State.selected
        board: new Board State.board
    next(data)

History.undo = () ->
  if history.length > 0
    oldState = history.pop()
    State[k] = v for k, v of oldState