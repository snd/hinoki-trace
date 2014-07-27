# do -> = module pattern in coffeescript
do ->

  hinokiTrace = {}

  ###################################################################################
  # node.js or browser?

  if not window? and module?.exports?
    util = require 'util'

  if window?
    window.hinokiTrace = hinokiTrace
  else if module?.exports?
    module.exports = hinokiTrace
  else
    throw new Error 'either the `window` global or the `module.exports` global must be present'

  ###################################################################################
  # util

  hinokiTrace.pad = (n, length = 7, char = '0') ->
    pad = new Array(1 + length).join(char)
    (pad + n).slice(-pad.length)

  hinokiTrace.isObject = (x) ->
    x is Object(x)

  hinokiTrace.isThenable = (x) ->
    hinokiTrace.isObject(x) and 'function' is typeof x.then

  ###################################################################################
  # tracing

  hinokiTrace.newTraceIdGenerator = ->
    id = 0
    ->
      id++

  hinokiTrace.valueToString = (value) ->
    if 'object' is typeof value
      if util?
        util.inspect(value)
      else
        value
    else
      value

  hinokiTrace.defaultTraceCallback = (trace) ->
    prefix = "TRACE #{hinokiTrace.pad trace.traceId, 10, ' '} | #{trace.id} |"
    switch trace.type
      when 'call'
        console.log(
          prefix
          '<-'
          trace.args.map(hinokiTrace.valueToString)
        )
      when 'return'
        console.log(
          prefix
          '->'
          hinokiTrace.valueToString(trace.value)
        )
      when 'promiseReturn'
        console.log(
          prefix
          '=>'
          'promise'
          # hinokiTrace.valueToString(trace.promise)
        )
      when 'promiseResolve'
        console.log(
          prefix
          '=>'
          hinokiTrace.valueToString(trace.value)
        )

  hinokiTrace.newTracingResolver = (traceFunctions, options = {}) ->
    options.callback ?= hinokiTrace.defaultTraceCallback
    options.nextTraceId ?= hinokiTrace.newTraceIdGenerator()

    (container, id, inner) ->
      factory = inner()

      unless factory?
        return

      unless id in traceFunctions
        return factory

      delegateFactory = (dependencies...) ->
        value = factory(dependencies...)
        unless 'function' is typeof value
          throw new Error "tracing #{id} but factory didn't return a function"
        (args...) ->
          traceId = options.nextTraceId()

          options.callback
            type: 'call'
            id: id
            traceId: traceId
            args: args

          valueOrPromise = value args...

          if hinokiTrace.isThenable valueOrPromise
            options.callback
              type: 'promiseReturn'
              id: id
              traceId: traceId
              promise: valueOrPromise
            valueOrPromise.then (value) ->
              options.callback
                type: 'promiseResolve'
                id: id
                traceId: traceId
                value: value
              return value
          else
            options.callback
              type: 'return'
              id: id
              traceId: traceId
              value: valueOrPromise
            return valueOrPromise

      delegateFactory.$inject = if factory.$inject? then factory.$inject else hinokiTrace.parseFunctionArguments factory

      return delegateFactory
