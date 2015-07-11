###
  Application entry point.
  Purpose is to wire up everything else.
###

# Require CSS and other assets
require './glyphs.css'
require './styles.sass'

# Require index.html
require 'file?name=[name].[ext]!./index.html'

# Require application components
Renderer = require './app/renderer.coffee'
Events   = require './app/events.coffee'
Log      = require './app/log.coffee'
History  = require './app/history.coffee'

# Add needed services to event emitter before we start adding handlers.
# Note that first-added is first-called on the request and last-called on the response.
Events.addService Renderer.service
Events.addService History.service

Log.info "Application Started"
Renderer.loop()