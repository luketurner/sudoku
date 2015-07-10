###
  Global app state.
  Purpose is to provide a consistent clearinghouse for all application data.

  State is represented as an Immutable object. This object is hidden from view
  because the semantics of immutability make setting
  module.exports = Immutable.Map(), for example, to be problematic because it
  cannot be reassigned outside this file.

  Instead, State access is mediated with Cursors, which are persistent
  "pointers" to specific parts of a nested immutable data structure. Once you
  have a cursor, you can use that to get or set data in the internal state.
  For more details on cursors, see:
  https://github.com/facebook/immutable-js/tree/master/contrib/cursor

  cursor()
  cursor(vector path)
    Gets a cursor which can be used to read/write application state.
    Don't keep a cursor too long; they do not update their values because the
    underlying data is immutable. use State.cursor() to get a cursor for the 
    whole state map (e.g. for equality checking).

    curs = State.cursor(['path', 'to', 'your', 'data'])
    curs.deref() # returns value of the cursor when it was made
    curs.update((val) -> val + 1) # updates the cursor's backing value in the global state

###

Board = require '../board.coffee'

State = module.exports =
  selected: null
  board: new Board
  lockedSquares: []
