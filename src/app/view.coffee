_       = require 'lodash'
h       = require 'virtual-dom/h'
State   = require './state.coffee'
Events  = require './events.coffee'
History = require './history.coffee'
Board   = require './board.coffee'
Timer   = require './timer.coffee'

registerEvents = () ->
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
    State.board = ("" for [0..80])
    State.lockedSquares = []
    Timer.reset()

  Events.addHandler "game:new", ->
    State.board = Board.generateNew(25, 30)
    State.lockedSquares = (i for v, i in State.board when v.length == 1)
    Timer.reset()

  Events.addHandler "game:solve", ->
    State.board = Board.solve(State.board)
    State.lockedSquares = (i for v, i in State.board when v.length == 1)
    Timer.reset()

  Events.addHandler "game:undo", -> History.undo()
  Events.addHandler "game:redo", -> History.redo()
  Events.addHandler "game:undoAll", ->  History.undoAll()
  Events.addHandler "game:redoAll", -> History.redoAll()

renderSquare = (val, index) ->
  classes = ".square"
  selected = State.selected
  if selected?
    if index is selected then classes += ".sel" else if Board.sameUnit(index, selected) then classes += ".rel"
  if Board.isInvalid(State.board, index) then classes += ".invalid"
  if index in State.lockedSquares then classes += ".locked"
  h ".square-border", { onclick: -> Events.emit type: "game:square", value: index },
    h(classes,
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

  [h "a", { href: "http://github.org/luketurner/sudoku" }, "s\u03BCdoku v0.8.0"
   h "div", "filled #{filled} / guessed #{guessed} / empty #{empty}"
   h "div", ["elapsed ", h("span#game-timer", "00:00")]]

# Helper that creates a button which emits one event when left-clicked,
# and a different event when right-clicked. Long-pressing the button
# also emits the right-click event (for mobile clients).
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
  registerEvents: registerEvents
  render: () ->
    h 'div#app', [
      h ".menu", [
        doubleButton "", "game:undo", "game:undoAll", "undo / reset", ".icon-undo"
        doubleButton "", "game:redo", "game:redoAll", "redo / redo-all", ".icon-redo"
        h ".info", infoText()
        doubleButton "", { type: "game:new", historical: true }, { type: "game:clear", historical: true }, "new / clear", ".icon-clear"
        doubleButton "", "game:hint", { type: "game:solve", historical: true }, "hint / solve", ".icon-solve"]
      h ".sudoku-board",
        renderSquare(val, i) for val, i in State.board
      h ".sudoku-nums",
        renderNum(n) for n in "123456789"]