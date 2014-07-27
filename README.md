# hinoki-trace

[![NPM version](https://badge.fury.io/js/hinoki-trace.svg)](http://badge.fury.io/js/hinoki-trace)
[![Build Status](https://travis-ci.org/snd/hinoki-trace.svg?branch=master)](https://travis-ci.org/snd/hinoki-trace)
[![Dependencies](https://david-dm.org/snd/hinoki-trace.svg)](https://david-dm.org/snd/hinoki-trace)

> tracing for functions returned by hinoki factories

built-in support for promise-returning functions

hinoki-trace makes debugging hinoki applications a blast :)

### [example.js](example.js)

trace output on the console looks like this:

```
TRACE          0 | squared | <- [ 1 ]
TRACE          1 | times | <- [ 1, 1 ]
TRACE          1 | times | -> 1
TRACE          0 | squared | => promise
TRACE          2 | squared | <- [ 2 ]
TRACE          3 | times | <- [ 2, 2 ]
TRACE          3 | times | -> 4
TRACE          2 | squared | => promise
TRACE          4 | squared | <- [ 3 ]
TRACE          5 | times | <- [ 3, 3 ]
TRACE          5 | times | -> 9
TRACE          4 | squared | => promise
TRACE          6 | squared | <- [ 4 ]
TRACE          7 | times | <- [ 4, 4 ]
TRACE          7 | times | -> 16
TRACE          6 | squared | => promise
TRACE          8 | squared | <- [ 5 ]
TRACE          9 | times | <- [ 5, 5 ]
TRACE          9 | times | -> 25
TRACE          8 | squared | => promise
TRACE          0 | squared | => 1
TRACE          4 | squared | => 9
TRACE          2 | squared | => 4
TRACE          8 | squared | => 25
TRACE          6 | squared | => 16
```

### todo

- support not just factories but tracing of values which are functions as well
- document options (`callback` and `nextTraceId`)
- make it possibly to register a different handler for each traced function
by passing an object instead of an array
  - a value of `true` just uses the default handler
- add support for performance profiling
  - build on top instead of built-in
- make the example more interesting

### [license: MIT](LICENSE)
