svg = require 'virtual-dom/virtual-hyperscript/svg'
_ = require 'lodash'
diff = require 'virtual-dom/diff'
patch = require 'virtual-dom/patch'
h = require 'virtual-dom/h'

History = []

State =
  selected: []
  board: (() -> nums: [] for y in [0..8] for x in [0..8])() # note: wrapped in a closure to avoid polluting module scope with x, y variables

# Square coordinate inclusion predicates
sameChunk  = (x1, y1, x2, y2) -> (x1-1) // 3 == (x2-1) // 3 and (y1-1) // 3 == (y2-1) // 3
sameRow    = (x1, y1, x2, y2) -> y1 == y2
sameCol    = (x1, y1, x2, y2) -> x1 == x2
sameSquare = (x1, y1, x2, y2) -> x1 == x2 and y1 == y2
sameSet    = (x1, y1, x2, y2) -> sameChunk(x1, y1, x2, y2) or sameRow(x1, y1, x2, y2) or sameCol(x1, y1, x2, y2)

# Square coordinate group generators
rowFor   = (x0, y0) -> [x0, y] for y in [1..9] when y isnt y0
colFor   = (x0, y0) -> [x, y0] for x in [1..9] when x isnt x0
chunkFor = (x0, y0) -> _.flatten([x+1, y+1] for y in [0..8] when y // 3 == (y0-1) // 3 and not sameSquare x0, y0, x+1, y+1 for x in [0..8] when x // 3 == (x0-1) // 3)
setFor   = (x0, y0) -> _.union chunkFor(x0, y0), rowFor(x0, y0), colFor(x0, y0)

# determines if a space is valid
# FIXME TODO
isValid = (state, x0, y0) ->
  nums0 = state.board[x0-1][y0-1].nums
  if nums0.length != 1 then return true
  for [x, y] in setFor x0, y0
    if state.board[x-1][y-1].nums.length == 1 and state.board[x-1][y-1].nums[0] == nums0[0] then return false
  return true

renderSquare = (state, x, y) ->
  classes = ".square"
  [sx, sy] = state.selected
  nums = state.board[x-1][y-1].nums
  if x == sx and y == sy then classes += ".sel" else if sameSet x, y, sx, sy then classes += ".rel"
  if not isValid state, x, y then classes += ".invalid"
  h(classes,
    onclick: () -> raiseEvent type: "board", value: [x, y],
    if nums.length == 1 then nums[0].toString() else h(".mininum", if i in nums then i.toString() else " ") for i in [1..9])

renderNum = (state, n) ->
  [sx, sy] = state.selected
  classes = ".num"
  if sx? and _.includes state.board[sx-1][sy-1].nums, n
    classes += ".sel"
  h classes,
    onclick: () -> raiseEvent type: "num", value: n,
    n.toString()

render = (state) -> h 'div#app', [
  h ".menu", [
    h("button", { onclick: () -> raiseEvent type: "clear" }, "Clear")
    h("button", { onclick: () -> raiseEvent type: "new" }, "Generate")
    h("button", { onclick: () -> raiseEvent type: "undo" }, "Undo")]
  h ".sudoku-board",
    renderSquare(state, x, y) for x in [1..9] for y in [1..9]
  h ".sudoku-nums",
    renderNum(state, n) for n in [1..9]]

updateState = (path, historical, f) ->
  oldVal = _.get State, path
  newVal = f oldVal
  if newVal == oldVal then return false
  _.set State, path, newVal
  if historical then History.push path: path, old: oldVal, new: newVal
  true

# Subscriptions
raiseEvent = (e) ->
  console.log e
  updated = false
  switch e.type
    when "num"
      n = e.value
      [sx, sy] = State.selected
      if sx?
        updated = updateState ["board", sx-1, sy-1, "nums"], true,
          (nums) -> if _.includes nums, n then _.without nums, n else _.union nums, [n]
    when "board"
      square = e.value
      sel = State.selected
      updated = updateState "selected", false, (sel) -> if _.matches(square)(sel) then [] else square
    when "clear"
      updated = updateState "board", true, () -> nums: [] for y in [0..8] for x in [0..8]
    when "new" then null
    when "undo"
      entry = History.pop()
      console.log entry
      updated = updateState entry.path, false, () -> entry.old
    else null
  if updated
    updateDom State

tree = h 'div#app'

updateDom = (newState) ->
  newTree = render newState
  patch document.getElementById("app"), diff(tree, newTree)
  tree = newTree
  window.localStorage.setItem("state", State)

updateDom State
