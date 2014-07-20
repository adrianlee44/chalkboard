module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    nodeunit:
      files: ["test/**/*_test.coffee"]

    coffeelint:
      options:
        indentation:     2
        no_stand_alone_at:
          level: "error"
        no_empty_param_list:
          level: "error"
        max_line_length:
          level: "ignore"

      gruntfile:
        files:
          src: "Gruntfile.coffee"

      test:
        files:
          src: ["test/**/*.coffee"]

      src:
        files:
          src: ["src/*.coffee"]

    watch:
      gruntfile:
        files: "<%= coffeelint.gruntfile.files.src %>"
        tasks: ["coffeelint:gruntfile"]

      src:
        files: "src/**/*.coffee"
        tasks: ["coffeelint:src", "nodeunit", "chalkboard"]

      test:
        files: "<%= coffeelint.test.files.src %>"
        tasks: ["coffeelint:test", "nodeunit"]

    chalkboard:
      src:
        files:
          "README.md": ["src/chalkboard.coffee"]

  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # Default task.
  grunt.registerTask "default", ["coffeelint", "nodeunit", "chalkboard"]
