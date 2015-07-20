###
  timer - a simple component that encapsulates a game timer.
###

State  = require './state.coffee'
Events = require './events.coffee'

timeProp   = "elapsedTime"
intervalId = null
update     = -> Events.emit type: "game:timer"

module.exports =
  registerEvents: ->
    Events.addHandler "game:timer", ->
      ++State[timeProp]
  reset: ->
    State[timeProp] = 0
    update()
  start: -> if not intervalId then intervalId = window.setInterval(update, 1000)
  stop: -> if intervalId then window.clearInterval(intervalId)
  displayText: ->
    s = State[timeProp]
    min = (if s // 60 < 10 then "0" else "") + s // 60
    sec = (if s % 60 < 10 then "0" else "") + s % 60
    "#{min}:#{sec}"
