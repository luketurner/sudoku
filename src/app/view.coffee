_       = require 'lodash'
h       = require 'virtual-dom/h'
State   = require './state.coffee'
Events  = require './events.coffee'
History = require './history.coffee'
Board   = require '../board.coffee'

registeredEvents = false
registerEvents = () ->
  registeredEvents = true

  Events.addHandler "game:num", (e) ->
    n = e.value
    si = State.selected
    board = State.board
    if si? and not (si in State.lockedSquares)
      if n in board[si]
        board[si] = if e.all then "" else board[si].replace(n, "")
      else
        board[si] = if e.all then "123456789" else board[si] + n

  Events.addHandler "game:square", (e) ->
    si = e.value
    State.selected = if State.selected is si then null else si

  Events.addHandler "game:clear", ->
    State.board.reset()
    State.lockedSquares = []

  Events.addHandler "game:new", ->
    State.board.generateNew(25, 30)
    State.lockedSquares = (i for v, i in State.board when v.length == 1)

  Events.addHandler "game:solve", ->
    State.board.solve()
    State.lockedSquares = (i for v, i in State.board when v.length == 1)

  Events.addHandler "game:undo", -> History.undo()
  Events.addHandler "game:redo", -> History.redo()
  Events.addHandler "game:undoAll", ->  History.undoAll()
  Events.addHandler "game:redoAll", -> History.redoAll()

  Events.emit type: "game:new", historical: true

renderSquare = (val, index) ->
  classes = ".square"
  selected = State.selected
  if selected?
    if index is selected then classes += ".sel" else if State.board.sameUnit(index, selected) then classes += ".rel"
  if State.board.isInvalid(index) then classes += ".invalid"
  if index in State.lockedSquares then classes += ".locked"
  h(classes,
    onclick: -> Events.emit type: "game:square", value: index,
    if val.length is 1 then val else h(".mininum", if i in val then i else " ") for i in "123456789")

renderNum = (n) ->
  selected = if State.selected? then State.board[State.selected] else ""
  classes = ".num"
  if n in selected
    classes += ".sel"
  leftev = type: "game:num", value: n, historical: true
  rightev = _.merge all: true, leftev
  doubleButton n, leftev, rightev, n, classes

infoText = () ->
  filled = (x for x in State.board when x.length == 1).length
  guessed = (x for x in State.board when x.length > 1).length
  empty = 81 - (filled + guessed)

  h "div", "filled #{filled} / guessed #{guessed} / empty #{empty}"


doubleButton = (text, leftev, rightev, title, classes) ->
  if typeof leftev is "string" then leftev = type: leftev
  if typeof rightev is "string" then rightev = type: rightev
  timeout = null
  rightfn = ->
    timeout = null
    Events.emit rightev
  attributes =
    title: title ? ""
    onmouseup: ->
      if timeout isnt null
        clearTimeout(timeout)
        Events.emit leftev
    onmousedown: (e) ->
      if e.button is 2
        e.preventDefault()
        rightfn()
      if e.button is 0
        timeout = window.setTimeout rightfn, 1000
    oncontextmenu: (e) -> e.preventDefault()
  h("button" + (classes ? ""), attributes, text)

module.exports =
  render: () ->
    registerEvents() if not registeredEvents
    h 'div#app', [
      h "h1", "Sudoku"
      h ".menu", [
        doubleButton "<-",  "game:undo",  "game:undoAll",   "undo / reset"
        doubleButton "->",  "game:redo",  "game:redoAll", "redo / redo-all"
        h ".info", infoText()
        doubleButton "| |", { type: "game:new", historical: true }, { type: "game:clear", historical: true }, "new / clear"
        doubleButton "|x|", { type: "game:solve", historical: true }, "game:hint",    "solve / hint"]
      h ".sudoku-board",
        renderSquare(val, i) for val, i in State.board
      h ".sudoku-nums",
        renderNum(n) for n in "123456789"]