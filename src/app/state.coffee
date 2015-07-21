###
  Global app state.
  Purpose is to provide a consistent clearinghouse for all application data.
###

State = module.exports =
  selected: null
  board: ("" for [0..80])
  lockedSquares: []
  elapsedTime: 0
  showExtraTools: false
  squaresToGenerate: 25