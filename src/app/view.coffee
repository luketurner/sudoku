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
      board[si] = if n in board[si] then board[si].replace(n, "") else board[si] + n


  Events.addHandler "game:square", (e) ->
    si = e.value
    State.selected = if State.selected is si then null else si

  Events.addHandler "game:clear", (e) ->
    State.board.reset()
    State.lockedSquares = []

  Events.addHandler "game:new", (e) ->
    State.board.generateNew(25, 30)
    State.lockedSquares = (i for v, i in State.board when v.length == 1)

  Events.addHandler "game:solve", (e) ->
    State.board.solve()
    State.lockedSquares = (i for v, i in State.board when v.length == 1)

  Events.addHandler "game:undo", (e) ->
    History.undo()

  Events.emit type: "game:new"

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
  el = "button.num"
  if n in selected
    el += ".sel"
  h el,
    onclick: -> Events.emit type: "game:num", value: n, historical: true
    n

infoText = () ->
  filled = (x for x in State.board when x.length == 1).length
  guessed = (x for x in State.board when x.length > 1).length
  empty = 81 - (filled + guessed)
  "filled #{filled} / guessed #{guessed} / empty #{empty}"

module.exports =
  render: () ->
    registerEvents() if not registeredEvents
    h 'div#app', [
      h "h1", "Sudoku"
      h ".menu", [
        h("button", { onclick: () -> Events.emit type: "game:undo" }, "Undo")
        h("button", { onclick: () -> Events.emit type: "game:clear", historical: true }, "Clear")
        h("button", { onclick: () -> Events.emit type: "game:new", historical: true }, "Generate")
        h("button", { onclick: () -> Events.emit type: "game:solve", historical: true }, "Solve")]
      h("p.info", infoText())
      h ".sudoku-board",
        renderSquare(val, i) for val, i in State.board
      h ".sudoku-nums",
        renderNum(n) for n in "123456789"]