###
  Singleton event emitter.
  Purpose is to keep track of what needs to be called when.

  In simplest form, an event emitter is just a kind of dispatch table, where
  you add handlers to the table and then the emit() call looks up the handler
  for the specified event and calls it.

  This implementation also adds "services", which are middleware functions
  that are composed with all event handlers. Using services was chosen over
  allowing multiple handlers or "global" handlers because services can do work
  both before and after the event handler executes.

  addHandler(string eventType, fn handler)
    Call addHandler to add a handler for a new event type.
    Only one handler is permitted per event type.

    Events.addHandler("app:sampleevent", (eventData) -> ... )

  addService(fn service)
    Call addService to add a middleware handler, called a "service" to distinguish
    from regular handlers. All services are triggered for every event. 
    They let you add logic that runs before or after the event handler.
    Services are expected to use the following middleware pattern:

    Events.addService (next) ->
      # setup stuff
      (data) ->
        # pre-execute stuff
        next(data)
        # post-execute stuff

  emit(object eventData)
    Call emit to emit an event object. The "type" key of the object must
    indicate the event type. Attempts to emit an event with no handler will
    fail. Handlers are passed the whole object passed into emit, so use it to 
    send context or data.

    Events.emit(type: "app:sampleevent", value: "a value")

###

Log          = require './log.coffee'
Events       = module.exports = {}

handlers     = {}
services     = []
withServices = (fn) -> (fn = svc(fn) for svc in services) and fn

Events.addHandler = (type, handler) ->
  if type of handlers then Log.error "overwriting existing handler for type '#{type}'"
  handlers[type] = withServices handler

Events.addService = (svc) ->
  if svc in services then Log.warn "duplicate service added"
  if Object.keys(handlers).length > 0
    Log.warn "service registered after handler(s), may not be called"
  services.push(svc)

Events.emit = (data) ->
  if not data.type then Log.error "no type property in event data", data
  if not data.type of handlers
    Log.error "no handlers for event type", data
    return
  Log.debug "emitted #{data.type}"
  try
    handlers[data.type] data
  catch error
    Log.error "exception while handling event. Event data:", data, " Ex:", error