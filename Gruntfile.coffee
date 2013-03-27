module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    nodeunit:
      files: ["test/**/*_test.coffee"]

    coffeelint:
      options:
        indentation: 2

      test:
        files:
          src: ["test/**/*.coffee"]

      src:
        files:
          src: ["src/*.coffee"]

    watch:
      gruntfile:
        files: "<%= jshint.gruntfile.src %>"
        tasks: ["jshint:gruntfile"]

      src:
        files: "src/*.coffee"
        tasks: ["default"]

      test:
        files: "<%= jshint.test.src %>"
        tasks: ["coffeelint:test", "nodeunit"]

    coffee:
      options:
        join: true
      src:
        files:
          "chalkboard.js": ["src/*.coffee"]

  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-nodeunit"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-coffeelint"

  # Default task.
  grunt.registerTask "default", ["coffee", "coffeelint", "nodeunit"]
