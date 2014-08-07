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

  hinokiTrace.newTracingFactoryResolver = (traceFunctions, options = {}) ->
    options.callback ?= hinokiTrace.defaultTraceCallback
    options.nextTraceId ?= hinokiTrace.newTraceIdGenerator()

    (container, name, inner) ->
      factory = inner container, name

      unless factory?
        return

      unless name in traceFunctions
        return factory

      delegateFactory = (dependencies...) ->
        value = factory(dependencies...)
        unless 'function' is typeof value
          throw new Error "tracing #{name} but factory didn't return a function"
        (args...) ->
          traceId = options.nextTraceId()

          options.callback
            type: 'call'
            name: name
            traceId: traceId
            args: args

          valueOrPromise = value args...

          if hinokiTrace.isThenable valueOrPromise
            options.callback
              type: 'promiseReturn'
              name: name
              traceId: traceId
              promise: valueOrPromise
            valueOrPromise.then (value) ->
              options.callback
                type: 'promiseResolve'
                name: name
                traceId: traceId
                value: value
              return value
          else
            options.callback
              type: 'return'
              name: name
              traceId: traceId
              value: valueOrPromise
            return valueOrPromise

      delegateFactory.$inject = if factory.$inject? then factory.$inject else hinokiTrace.parseFunctionArguments factory
      delegateFactory.$trace = true

      return delegateFactory
