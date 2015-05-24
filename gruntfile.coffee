module.exports = (grunt) ->
  grunt.initConfig

    watch:
      coffee:
        files: "coffee/**/*.coffee"
        tasks: ["coffeelint", "coffee"]
        options: { livereload: true }
      configFiles:
        files: [ 'gruntfile.coffee'],
        options:
          reload: true

    coffeelint:
      options:
        'max_line_length': {'level': 'ignore'}
      client:
        files:
          src: ['coffee/**/*.coffee']

    coffee:
      client:
        options:
          join: true
          #bare: true
          sourceMap: true
        files:
          'public/js/main.js': 'coffee/**/*.coffee'


  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'server', 'Start a custom web server', ()->
    grunt.log.writeln('Started web server on port 3000')
    require('./index.coffee')

  # Default task(s).
  grunt.registerTask "default", ["server","coffeelint", "coffee", "watch"]
