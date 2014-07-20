###
@chalk overview
@name Chalkboard.js

@description
[![Build Status](http://img.shields.io/travis/adrianlee44/chalkboard.svg?style=flat)](https://travis-ci.org/adrianlee44/chalkboard)
An npm package that generate better documentation


@author Adrian Lee
@email adrian@adrianlee.me
@copyright 2014 Adrian Lee
@url https://github.com/adrianlee44/chalkboard
@license MIT

@dependencies
- commander
- wrench
- marked
- lodash

@example
```coffeescript
#
# @chalk overview
# @name example
# @description
# This is an example description for an example in readme.
# @param {String} name Just a random name
# @param {Boolean} work Does this actually work?
# @returns {String} Just another value
#
```

@TODO
[TODO Wiki](https://github.com/adrianlee44/chalkboard/wiki/TODO)
###

###
@chalk overview
@name Getting Started
@description
The easiest way to use chalkboard will probably be to install it globally.

To do so, install the module with:
```
npm install -g chalkboard
```
###

###
@chalk overview
@name Supported Tags
@description
[Wiki Page](https://github.com/adrianlee44/chalkboard/wiki/Supported-Tags)
###

###
@chalk overview
@name Usage
@description
 Usage: chalkboard [options] [FILES...]
 Options:
   -h, --help           output usage information
   -V, --version        output the version number
   -o, --output [DIR]   Documentation output file
   -j, --join [FILE]    Combine all documentation into one page
   -f, --format [TYPE]  Output format. Default to markdown
   -p, --private        Parse comments for private functions and varibles
   -h, --header         Only parse the first comment block
###

format    = require "./format"
languages = require "../resources/languages.json"
parse     = require "./parse"
pkg       = require "../package.json"
write     = require "./write"

packages        = ["fs", "path", "wrench", "marked"]
lib             = {}
lib[requirePkg] = require requirePkg for requirePkg in packages
_               = require "lodash"

cwd = process.cwd()

defaults =
  format:  "markdown"
  output:  null
  join:    null
  header:  false
  private: false

#
# @chalk function
# @private
# @function
# @name compile
# @description
# Parse code into documentation
# @param   {String} code     Source code
# @param   {Object} options  User options
# @param   {String} filepath Path of the original file
# @returns {String}          Formatted documentation
#
compile = (code, options = {}, filepath) ->
  return unless filepath?

  lang = util.getLanguages filepath, options

  return null unless lang?

  parsed    = parse code, lang, options
  formatted = format parsed, options

  # TODO: Create plugin system to handle something like this
  formatted = lib.marked formatted if options.format is "html"
  return formatted

#
# @chalk function
# @private
# @function
# @name configure
# @description
# Configurate user options and validate file paths
# @param {Object} options User configurations
#
configure = (options) ->
  optsKeys = _.keys(defaults)
  opts     = _.extend {}, defaults, _.pick(options, optsKeys)

  if opts.output and opts.join
    throw new Error "Cannot use both output and join option at the same time"

  # clean the existing file if all comments are compiled to one location
  if opts.join?
    joinfilePath = lib.path.join cwd, opts.join

    # Clear the original file by write empty string into it
    lib.fs.unlinkSync(joinfilePath) if lib.fs.existsSync joinfilePath

  opts.files = options.args or []

  return opts

processFiles = (options)->
  opts = configure options

  process = (path) ->
    lib.fs.readFile path, (error, buffer) ->
      throw new Error(error) if error?

      source    = buffer.toString()
      formatted = compile source, opts, path

      if formatted
        relative  = lib.path.relative cwd, path
        writeFile = write relative, formatted, opts

      readFilename = lib.path.basename path
      console.log """Generated documentation for "#{readFilename}"."""

  for userFile in opts.files
    stat = lib.fs.statSync userFile

    if stat.isDirectory()
      documents = lib.wrench.readdirSyncRecursive userFile
      findAll   = _.compose _.unique, _.flatten
      documents = findAll documents

      for doc in documents
        docPath = lib.path.join cwd, userFile, doc
        stat    = lib.fs.existsSync(docPath) and lib.fs.statSync(docPath)
        process docPath if stat.isFile()

    else if stat.isFile()
      process lib.path.join(cwd, userFile)

module.exports = {
  parse,
  compile,
  format,
  write,
  processFiles,
  configure
}
