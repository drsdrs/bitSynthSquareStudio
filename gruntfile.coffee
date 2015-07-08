module.exports = (grunt) ->
  grunt.initConfig

    requirejs:
        compile:
          options:
            name: "cs!main"
            baseUrl: "public/src"
            out: "public/build/optimized.js"
            paths: 
              "cs": 'lib/cs'
              "coffee-script": 'lib/coffee-script'

    less:
      dev:
        options:
          paths: ["public"]
        files:
          "public/style.css": "public/less/main.less"

    simplemocha:
      dev:
        #src:"test/test"
        options:
          require: "coffee-script/register"
          slow: 20
          timeout: 100
          globals: ['should']
          #ui: 'bdd'
          reporter: 'list'
        src: ['./test/**/*.coffee']

    coffeelint:
      options:
        'max_line_length': {'level': 'ignore'}
      client:
        files:
          src: ["public/src/**/*.coffee"]

    watch:
        test:
          files: ["public/src/**/*.coffee", 'test/**/*.coffee']
          tasks: ["clear","simplemocha"]
        coffeelint:
          files: "public/src/**/*.coffee"
          tasks: ["coffeelint"]
        less:
          files: "public/less/**/*.less"
          tasks: ["less:dev"]
        configFiles:
          files: [ 'gruntfile.coffee', 'index.coffee', './server/*.coffee']
          options:
            reload: true
            livereload: true


  grunt.registerTask 'server', 'start', ()->
    require "coffee-script"
    require "./index"


  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-requirejs'
  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-clear'

  grunt.registerTask('test', 'simplemocha:dev');
  grunt.registerTask "runBuild", ["serverBuild", "watch"]
  grunt.registerTask "runDev", ["server","coffeelint", "less" ,"watch"]
  grunt.registerTask "build", ["requirejs"]
  grunt.registerTask "default", ["runDev"]
