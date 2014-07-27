# hinoki-trace

[![NPM version](https://badge.fury.io/js/hinoki-trace.svg)](http://badge.fury.io/js/hinoki-trace)
[![Build Status](https://travis-ci.org/snd/hinoki-trace.svg?branch=master)](https://travis-ci.org/snd/hinoki-trace)
[![Dependencies](https://david-dm.org/snd/hinoki-trace.svg)](https://david-dm.org/snd/hinoki-trace)

> tracing for functions returned by [hinoki](https://github.com/snd/hinoki) factories

- built-in support for promise-returning functions
- works in [node.js](#nodejs-setup) and the [browser](#browser-setup)
- hinoki-trace makes debugging hinoki applications a blast :)

### node.js setup

```
npm install hinoki-trace
```

```javascript
var hinokiTrace = require('hinoki-trace');
```

### browser setup

your markup should look something like the following

```html
<html>
  <body>
    <!-- content... -->

    <!-- hinoki requires bluebird -->
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/bluebird/1.2.2/bluebird.js"></script>
    <!--
      hinoki-trace obviously requires hinoki
      take src/hinoki.js from the hinoki repository and include it
    -->
    <script type="text/javascript" src="hinoki.js"></script>
    <!-- take src/hinoki-trace.js from this repository and include it -->
    <script type="text/javascript" src="hinoki-trace.js"></script>
    <script type="text/javascript" src="example.js"></script>
  </body>
</html>
```

[hinoki-trace.js](src/hinoki-trace.js) makes the global
variable `hinokiTrace` available

*its best to fetch bluebird with [bower](http://bower.io/),
[hinoki with npm](https://www.npmjs.org/package/hinoki),
[hinoki-trace with npm](https://www.npmjs.org/package/hinoki-trace),
and then use
a build system like [gulp](http://gulpjs.com/) to bring everything together*


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
- add timestamps to trace output

### [license: MIT](LICENSE)
