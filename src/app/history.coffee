###
  History component, which saves changes in state and provides undo/redo functions.
  History is stored in localStorage for persistence. The history component handles its own persistence, so that the
  persistence component does not have to peek at our internal data.
  Will store at most 100 history elements, which prevents it from growing infinitely in localStorage.
###

_     = require 'lodash'
State = require './state.coffee'

maxHistory = 100
history = []
currentIndex = -1
History = module.exports = {}

storeHistory = -> window.localStorage.setItem "history_arr", JSON.stringify(history)
storeIndex   = -> window.localStorage.setItem "history_index", currentIndex

load = (index) ->
  currentIndex = index
  state = history[index]
  State.board = _.clone state.board
  State.lockedSquares = _.clone state.lockedSquares
  State.selected = state.selected
  storeIndex()

History.service = (next) ->
  (data) ->
    next(data)
    if data.historical
      if currentIndex + 1 < history.length then history = history.slice(0, currentIndex + 1)
      if history.length > maxHistory then history.shift()
      history.push
        selected: State.selected
        board: _.clone State.board
        lockedSquares: _.clone State.lockedSquares
      currentIndex = history.length - 1
      storeHistory()
      storeIndex()

History.loadFromStorage = ->
  index = window.localStorage.getItem("history_index")
  arrayString = window.localStorage.getItem("history_arr")
  if index is null or arrayString is null then return false
  try
    history = JSON.parse(arrayString)
    load(parseInt(index, 10))
    true
  catch
    false

History.length = -> history.length
History.undo = -> if currentIndex > 0 then load(currentIndex - 1)
History.redo = -> if history.length > currentIndex + 1 then load(currentIndex + 1)
History.undoAll = -> if currentIndex > 0 then load(0)
History.redoAll = -> if history.length > currentIndex + 1 then load(history.length - 1)
History.clear = ->
  history = []
  currentIndex = -1