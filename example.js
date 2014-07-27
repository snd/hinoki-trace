var hinoki = require('hinoki');
var trace = require('hinoki-trace');
var Promise = require('bluebird');

var container = {};

container.factories = {
  times: function() {
    return function(a, b) {
      return a * b;
    };
  },
  squared: function(times) {
    return function(a) {
      return Promise.delay(times(a, a), 100);
    };
  }
};

container.factoryResolvers = [];
container.factoryResolvers.push(trace.newTracingResolver(['times', 'squared']));

hinoki.get(container, 'squared').then(function(squared) {
  squared(3); // -> 9
});
