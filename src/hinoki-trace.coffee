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
    prefix = "TRACE #{hinokiTrace.pad trace.traceId, 10, ' '} | #{trace.name} |"
    switch trace.type
      when 'call'
        console.log(
          prefix
          '<-'
          (if util? then util.inspect trace.args else trace.args)
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

  hinokiTrace.newTracingResolver = (names, options = {}) ->
    options.callback ?= hinokiTrace.defaultTraceCallback
    options.nextTraceId ?= hinokiTrace.newTraceIdGenerator()

    resolver = (query, inner) ->
      result = inner query

      # nothing to trace
      unless result?
        return

      # we only trace factories
      if result.value?
        return result

      # we don't trace this factory
      unless query.name in names
        return result

      factoryDelegate = (dependencies...) ->
        f = result.factory(dependencies...)
        unless 'function' is typeof f
          throw new Error "tracing #{result.name} but factory didn't return a function"
        (args...) ->
          traceId = options.nextTraceId()

          options.callback
            type: 'call'
            name: result.name
            traceId: traceId
            args: args

          valueOrPromise = f args...

          if hinokiTrace.isThenable valueOrPromise
            options.callback
              type: 'promiseReturn'
              name: result.name
              traceId: traceId
              promise: valueOrPromise
            valueOrPromise.then (value) ->
              options.callback
                type: 'promiseResolve'
                name: result.name
                traceId: traceId
                value: value
              return value
          else
            options.callback
              type: 'return'
              name: result.name
              traceId: traceId
              value: valueOrPromise
            return valueOrPromise

      factoryDelegate.$inject = if result.factory.$inject?
        result.factory.$inject
      else
        hinokiTrace.parseFunctionArguments result.factory
      factoryDelegate.$trace = true

      {
        factory: factoryDelegate
        name: result.name
        container: result.container
        resolver: resolver
      }

    resolver.$name = 'tracingResolver'
    return resolver
