module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    nodeunit:
      files: ["test/**/*_test.js"]

    jshint:
      options:
        jshintrc: ".jshintrc"

      gruntfile:
        src: "Gruntfile.js"

      bin:
        src: ["bin/**/*.js"]

      test:
        src: ["test/**/*.js"]

    watch:
      gruntfile:
        files: "<%= jshint.gruntfile.src %>"
        tasks: ["jshint:gruntfile"]

      lib:
        files: "<%= jshint.bin.src %>"
        tasks: ["jshint:bin", "nodeunit"]

      test:
        files: "<%= jshint.test.src %>"
        tasks: ["jshint:test", "nodeunit"]


  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-nodeunit"
  grunt.loadNpmTasks "grunt-contrib-jshint"
  grunt.loadNpmTasks "grunt-contrib-watch"

  # Default task.
  grunt.registerTask "default", ["jshint", "nodeunit"]