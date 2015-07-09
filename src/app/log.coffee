###
  Logging utility.
  Purpose is to make logging convenient, consistent, and easy to adjust.

  Supports 4 log levels: error, warn, info, debug

  error(msgs...)
  warn(msgs...)
  info(msgs...)
  debug(msgs...)
    Logs the messages if the log level is sufficiently high.

    Log.warn("this might be a problem")

###

Log = module.exports = {}

Log.logLevel = 3
Log.prefix = "[app-log] "
Log.levelNames = ["ERROR", "WARN", "info", "debug"]
Log.logger = console

Log.log = (level, msgs) ->
  return if level > @logLevel
  @logger.log.apply(@logger, ["#{@prefix}#{@levelNames[level]}"].concat(msgs))

Log.error = (msgs...) -> @log(0, msgs)
Log.warn  = (msgs...) -> @log(1, msgs)
Log.info  = (msgs...) -> @log(2, msgs)
Log.debug = (msgs...) -> @log(3, msgs)