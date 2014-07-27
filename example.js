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
      return Promise.delay(times(a, a), Math.random() * 500);
    };
  }
};

container.factoryResolvers = [];
container.factoryResolvers.push(trace.newTracingResolver(['times', 'squared']));

hinoki.get(container, 'squared').then(function(squared) {
  Promise.all([1, 2, 3, 4, 5].map(function(x) {
    return squared(x);
  })).then(console.log);
});
