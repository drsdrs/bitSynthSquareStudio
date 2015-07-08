
requirejs.config({
  baseUrl: 'src',
  paths: {
    "cs": 'lib/cs',
    "coffee-script": 'lib/coffee-script'
  }
});


require([ 'cs!main' ])
