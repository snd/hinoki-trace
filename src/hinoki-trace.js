// Generated by CoffeeScript 1.7.1
var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
  __slice = [].slice;

(function() {
  var hinokiTrace, util;
  hinokiTrace = {};
  if ((typeof window === "undefined" || window === null) && ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null)) {
    util = require('util');
  }
  if (typeof window !== "undefined" && window !== null) {
    window.hinokiTrace = hinokiTrace;
  } else if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = hinokiTrace;
  } else {
    throw new Error('either the `window` global or the `module.exports` global must be present');
  }
  hinokiTrace.pad = function(n, length, char) {
    var pad;
    if (length == null) {
      length = 7;
    }
    if (char == null) {
      char = '0';
    }
    pad = new Array(1 + length).join(char);
    return (pad + n).slice(-pad.length);
  };
  hinokiTrace.isObject = function(x) {
    return x === Object(x);
  };
  hinokiTrace.isThenable = function(x) {
    return hinokiTrace.isObject(x) && 'function' === typeof x.then;
  };
  hinokiTrace.newTraceIdGenerator = function() {
    var id;
    id = 0;
    return function() {
      return id++;
    };
  };
  hinokiTrace.valueToString = function(value) {
    if ('object' === typeof value) {
      if (util != null) {
        return util.inspect(value);
      } else {
        return value;
      }
    } else {
      return value;
    }
  };
  hinokiTrace.defaultTraceCallback = function(trace) {
    var prefix;
    prefix = "TRACE " + (hinokiTrace.pad(trace.traceId, 10, ' ')) + " | " + trace.name + " |";
    switch (trace.type) {
      case 'call':
        return console.log(prefix, '<-', (util != null ? util.inspect(trace.args) : trace.args));
      case 'return':
        return console.log(prefix, '->', hinokiTrace.valueToString(trace.value));
      case 'promiseReturn':
        return console.log(prefix, '=>', 'promise');
      case 'promiseResolve':
        return console.log(prefix, '=>', hinokiTrace.valueToString(trace.value));
    }
  };
  return hinokiTrace.newTracingResolver = function(names, options) {
    var resolver;
    if (options == null) {
      options = {};
    }
    if (options.callback == null) {
      options.callback = hinokiTrace.defaultTraceCallback;
    }
    if (options.nextTraceId == null) {
      options.nextTraceId = hinokiTrace.newTraceIdGenerator();
    }
    resolver = function(query, inner) {
      var factoryDelegate, result, _ref;
      result = inner(query);
      if (result == null) {
        return;
      }
      if (result.value != null) {
        return result;
      }
      if (_ref = query.name, __indexOf.call(names, _ref) < 0) {
        return result;
      }
      factoryDelegate = function() {
        var dependencies, f;
        dependencies = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        f = result.factory.apply(result, dependencies);
        if ('function' !== typeof f) {
          throw new Error("tracing " + result.name + " but factory didn't return a function");
        }
        return function() {
          var args, traceId, valueOrPromise;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          traceId = options.nextTraceId();
          options.callback({
            type: 'call',
            name: result.name,
            traceId: traceId,
            args: args
          });
          valueOrPromise = f.apply(null, args);
          if (hinokiTrace.isThenable(valueOrPromise)) {
            options.callback({
              type: 'promiseReturn',
              name: result.name,
              traceId: traceId,
              promise: valueOrPromise
            });
            return valueOrPromise.then(function(value) {
              options.callback({
                type: 'promiseResolve',
                name: result.name,
                traceId: traceId,
                value: value
              });
              return value;
            });
          } else {
            options.callback({
              type: 'return',
              name: result.name,
              traceId: traceId,
              value: valueOrPromise
            });
            return valueOrPromise;
          }
        };
      };
      factoryDelegate.$inject = result.factory.$inject != null ? result.factory.$inject : hinokiTrace.parseFunctionArguments(result.factory);
      factoryDelegate.$trace = true;
      return {
        factory: factoryDelegate,
        name: result.name,
        container: result.container,
        resolver: resolver
      };
    };
    resolver.$name = 'tracingResolver';
    return resolver;
  };
})();
