_       = require 'lodash'
h       = require 'virtual-dom/h'
State   = require './state.coffee'
Events  = require './events.coffee'
History = require './history.coffee'
Board   = require '../game/board.coffee'

registeredEvents = false
registerEvents = () ->
  registeredEvents = true

  Events.addHandler "game:num", (e) ->
    n = e.value
    si = State.selected
    board = State.board
    if si?
      board[si] = if n in board[si] then board[si].replace(n, "") else board[si] + n

  Events.addHandler "game:square", (e) ->
    si = e.value
    State.selected = if State.selected is si then null else si

  Events.addHandler "game:clear", (e) ->
    State.board.reset()

  Events.addHandler "game:new", (e) ->
    State.board = new Board ["5", "3", "", "", "7", "", "", "", "", "6", "", "", "1", "9", "5", "", "", "", "", "9", "8", "", "", "", "", "6", "", "8", "", "", "", "6", "", "", "", "3", "4", "", "", "8", "", "3", "", "", "1", "7", "", "", "", "2", "", "", "", "6", "", "6", "", "", "", "", "2", "8", "", "", "", "", "4", "1", "9", "", "", "5", "", "", "", "", "8", "", "", "7", "9"]

  Events.addHandler "game:solve", (e) ->
    State.board.solve()

  Events.addHandler "game:undo", (e) ->
    History.undo()

renderSquare = (val, index) ->
  classes = ".square"
  selected = State.selected
  if selected?
    if index is selected then classes += ".sel" else if State.board.sameUnit(index, selected) then classes += ".rel"
  if State.board.isInvalid(index) then classes += ".invalid"
  h(classes,
    onclick: -> Events.emit type: "game:square", value: index,
    if val.length is 1 then val else h(".mininum", if i in val then i else " ") for i in "123456789")

renderNum = (n) ->
  selected = if State.selected? then State.board[State.selected] else ""
  classes = ".num"
  if n in selected
    classes += ".sel"
  h classes,
    onclick: -> Events.emit type: "game:num", value: n, historical: true
    n

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
      h ".sudoku-board",
        renderSquare(val, i) for val, i in State.board
      h ".sudoku-nums",
        renderNum(n) for n in "123456789"]