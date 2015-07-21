###
  timer - a simple component that encapsulates a game timer.
  Will put the current time into an element matching #game-timer
###

State = require './state.coffee'

minutify = (s) ->
  min = (if s // 60 < 10 then "0" else "") + s // 60
  sec = (if s % 60 < 10 then "0" else "") + s % 60
  "#{min}:#{sec}"

update = ->
  el = document.getElementById("game-timer")
  if not el then return
  el.textContent = minutify(++State.elapsedTime)

intervalId = null

module.exports =
  reset: ->
    State.elapsedTime = 0
    update()
  start: ->
    if not intervalId
      intervalId = window.setInterval(update, 1000)
      update()
  stop: -> if intervalId then window.clearInterval(intervalId)