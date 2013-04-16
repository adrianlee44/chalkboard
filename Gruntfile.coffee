module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    nodeunit:
      files: ["test/**/*_test.coffee"]

    coffeelint:
      options:
        indentation:         2
        no_empty_param_list: true
        no_tabs:             true
        no_stand_alone_at:   true

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
        files: "src/*.coffee"
        tasks: ["coffeelint:src", "coffee:src", "nodeunit"]

      test:
        files: "<%= coffeelint.test.files.src %>"
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
