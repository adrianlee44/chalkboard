program = require "commander"
pkg     = require "./package.json"

parse = ->

read = (files) ->
  console.log files

write = ->

run = (argv)->
  program
    .version(pkg.version)
    .usage("[options] [FILES...]")
    .option("-o, --output [DIR]", "Documentation output file")
    .option("-j, --join [FILE]", "Combine all documentation into one page")
    .parse argv

  read program.args

Chalkboard = module.exports = {parse, run}
