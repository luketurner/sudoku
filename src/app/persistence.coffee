###
  app/persistence - implements 2 types of persistence - url-based and localStorage-based.
  The URL-based persistence does *not* include any undo history (because it would make the URL too long).
  On the other hand, the localStorage-based persistence does include undo history.
  If both the localStorage and the fragment contain the same history (for example if you refresh the page),
  then the localStorage state will be preferred because it has undo history.
  But if the fragment does have state and it is different from the localStorage state, the fragment will be preferred,
  otherwise you could not open, for example, a bookmarked puzzle in a browser with a different puzzle in the localStorage.
###

_       = require 'lodash'
State   = require './state.coffee'
History = require './history.coffee'
Log     = require './log.coffee'

Persistence = module.exports = {}

Persistence.service = (next) ->
  (data) ->
    next(data)
    if data.historical # Note: for now, only update URL with historical (i.e. important) changes.
      stateJson = JSON.stringify State
      location.hash = "#" + window.btoa encodeURIComponent stateJson
      window.localStorage.setItem("state", stateJson)

Persistence.loadState = ->
  try
    fragmentState = JSON.parse decodeURIComponent window.atob location.hash.slice(1)
  catch
    fragmentState = null

  try
    localStoreState = JSON.parse window.localStorage.getItem("state")
  catch
    localStoreState = null

  if fragmentState is null and localStoreState is null then return false
  if fragmentState is null or _.matches(fragmentState)(localStoreState)
    _.merge State, localStoreState
    History.loadFromStorage()
    Log.info "Loaded state from localStorage"
  else
    _.merge State, fragmentState
    Log.info "Loaded state from URL fragment"
  true
