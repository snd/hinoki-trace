Promise = require 'bluebird'
hinoki = require 'hinoki'
trace = require '../src/hinoki-trace'

module.exports =

  'no-trace': (test) ->
    c =
      factories:
        plus: ->
          (a, b) -> a + b

    c.resolvers = []
    c.resolvers.push trace.newTracingResolver ['square'],
      callback: ->
        test.fail()

    hinoki.get(c, 'plus').then (plus) ->
      test.equals plus(1, 3), 4
      test.done()

  'single sync trace': (test) ->
    c =
      factories:
        plus: ->
          (a, b) -> a + b

    traces = []

    c.resolvers = []
    c.resolvers.push trace.newTracingResolver ['plus'],
      callback: (x) ->
        traces.push x

    hinoki.get(c, 'plus').then (plus) ->
      test.equals plus(1, 3), 4
      test.deepEqual traces, [
        {type: 'call', name: 'plus', traceId: 0, args: [1, 3]}
        {type: 'return', name: 'plus', traceId: 0, value: 4}
      ]
      test.done()

  'single async trace': (test) ->
    promises = []

    c =
      factories:
        plus: ->
          (a, b) ->
            promise = Promise.delay(a + b, 10)
            promises.push promise
            return promise

    traces = []

    c.resolvers = []
    c.resolvers.push trace.newTracingResolver ['plus'],
      callback: (x) ->
        traces.push x

    hinoki.get(c, 'plus').then (plus) ->
      promise = plus(1, 3)
      test.deepEqual traces, [
        {type: 'call', name: 'plus', traceId: 0, args: [1, 3]}
        {type: 'promiseReturn', name: 'plus', traceId: 0, promise: promises[0]}
      ]
      promise.then (sum) ->
        test.equals sum, 4
        test.deepEqual traces, [
          {type: 'call', name: 'plus', traceId: 0, args: [1, 3]}
          {type: 'promiseReturn', name: 'plus', traceId: 0, promise: promises[0]}
          {type: 'promiseResolve', name: 'plus', traceId: 0, value: 4}
        ]

        test.done()
