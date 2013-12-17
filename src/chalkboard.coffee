###
@chalk overview
@name Chalkboard.js

@description
[![Build Status](https://travis-ci.org/adrianlee44/chalkboard.png?branch=master)](https://travis-ci.org/adrianlee44/chalkboard)
An npm package that generate better documentation

@author Adrian Lee
@email adrian@adrianlee.me
@copyright 2013 Adrian Lee
@url https://github.com/adrianlee44/chalkboard
@license MIT

@dependencies
- commander
- wrench
- marked
- underscore

@example
```
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
@name Supported Tags
@description
[Wiki Page](https://github.com/adrianlee44/chalkboard/wiki/Supported-Tags)
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

util        = require "./lib/util"
pkg         = require "./package.json"
languages   = require "./resources/languages.json"
definitions = require "./resources/definitions/base.json"

packages        = ["fs", "path", "wrench", "marked"]
lib             = {}
lib[requirePkg] = require requirePkg for requirePkg in packages
_               = require "underscore"

commentRegex = /^\s*@(\w+)(?:\s*(.*))?$/
NEW_LINE     = /\n\r?/
cwd          = process.cwd()

defaults =
  format:  "markdown"
  output:  null
  join:    null
  header:  false
  private: false

#
# @chalk function
# @function
# @name parse
# @description
# Run through code and parse out all the comments
# @param   {String} code    Source code to be parsed
# @param   {Object} lang    Language settings for the file
# @param   {Object} options User settings (default {})
# @returns {Array}          List of objects with all the comment block
#
parse = (code, lang, options = {})->
  hasComment        = false
  multiLineKey      = ""
  commentBlockIndex = -1

  allSections    = []
  currentSection = {}
  argObject      = {}

  #
  # @chalk function
  # @function
  # @private
  # @name _setAttribute
  # @description
  # Helper function for setting objects
  # @param   {Object} object   Section object with information
  # @param   {String} key      Name of the tag
  # @param   {String} value    Value to be set
  # @param   {Object} options  Tag definitions (default {})
  # @returns {Number|String}   Return the length of the array or value
  #
  _setAttribute = (object, key, value, options = {}) ->
    if options.hasMultiple? and options.hasMultiple
      object[key] ?= []
      object[key].push value
    else
      object[key] ?= ""
      object[key] += value

  #
  # @chalk function
  # @function
  # @private
  # @name _getMultiLineKey
  # @description
  # multiLineKey has value a.b when used in multiple line argument
  # description. This function get the correct key based on the index
  # @param {Integer} index Key index
  #
  _getMultiLineKey = (index) ->
    keys  = multiLineKey.split "."
    index = keys.length + index if index < 0
    return "" if keys.length is 0 or index < 0 or index > keys.length
    keys[index]

  _multiLineSetAttribute = (value) ->
    object = if _(argObject).isEmpty() then currentSection else argObject
    value += "  \n"
    _setAttribute(object,
      _getMultiLineKey(-1),
      value,
      definitions[_getMultiLineKey(-1)]
    )

  _setArgObject = ->
    if multiLineKey and not _(argObject).isEmpty()
      _setAttribute(currentSection,
        _getMultiLineKey(0),
        argObject,
        definitions[_getMultiLineKey(0)]
      )

    argObject    = {}
    multiLineKey = ""

  #
  # @chalk function
  # @function
  # @private
  # @name _updateSection
  # @description
  # Check if current section or argument object are empty or not,
  # push object to the correct array if necessary
  #
  _updateSection = ->
    if hasComment and not _(currentSection).isEmpty()

      # Check if there is remaining argObject to be cleared
      _setArgObject()

      allSections.push currentSection
      currentSection = {}

    hasComment = false

  # Parse through each line in the file
  for line in code.split(NEW_LINE)

    # Check for starting and ending comment block
    blockRegex = if commentBlockIndex > -1 then lang.endRegex else lang.startRegex
    if match = line.match(blockRegex or lang.blockRegex)
      commentBlockIndex = if commentBlockIndex > -1 then -1 else match.index
      _updateSection() if commentBlockIndex is -1
      continue

    toMatchRegex = if commentBlockIndex > -1 then commentRegex else lang.commentRegex

    if match = line.match toMatchRegex
      key   = match[1]
      value = match[2]

      # Only parse section which user have specified
      if key is "chalk"
        # NOTE: With new section, the previous section comments should be stored and cleaned
        _updateSection()

        # Starting a new section
        hasComment           = true
        currentSection.chalk = value
        continue

      continue unless hasComment

      # Get the definition for the key
      def = definitions[key]

      if key? and def?
        _setArgObject()

        hasArgs = def.hasArgs? and def.hasArgs

        # Identifier section
        # =====================

        # check if the current key is an type identifier
        if def.typeIdentifier and key?
          type = if value then value else key

          if currentSection.type?
            currentSection.type.push type
          else
            currentSection.type = [key]
            continue

        # check if the current key is an access identifier
        if def.accessIdentifier and key?
          if currentSection.access?
            console.log """
              Cannot have multiple access specifier.
            """
          else
            currentSection.access = if key is "access" then value else key
            continue

        # For generic identifier
        value = true if def.identifier?

        # Following section is for tags with multiple arguments
        if hasArgs
          matchingRegex =
            switch key
              when "returns"
                /\{([\w\|]+)}(?:\s+(.*))?/
                # Type        description
              else
                /\{([\w\|\s]+)}\s+([\w\d_-]+)(?:\s+(.*))?/
                # Type            name       description

          # Check value for arguments
          # Used by param and returns tag
          argsMatch = value.match matchingRegex
          if argsMatch?
            argObject = type: argsMatch[1] or "undefined"
            switch key
              when "param"
                argObject.description  = argsMatch[3] or ""
                argObject.name         = argsMatch[2]
              when "returns"
                argObject.description = argsMatch[2] or ""

            argObject.description += "  \n" if argObject.description

            value = null

        # when multiple lines are allowed, update the multiLineKey
        if def.multipleLines
          multiLineKey = if hasArgs then "#{key}.description" else key

        if value?
          _setAttribute currentSection, key, value, def

        continue

      # When key doesn't exist and multi line key is set,
      # add the value to the original key
      setValue = if key? and not def? then line else value
      _multiLineSetAttribute setValue if multiLineKey and setValue?

    # if the current line is part of multiple line tag
    else if multiLineKey and ((lnMatch = line.match lang.lineRegex) or commentBlockIndex > -1)
      line    = line.substr commentBlockIndex
      content = if commentBlockIndex > -1 then line else (lnMatch?[1] or line)
      _multiLineSetAttribute content

    else if commentBlockIndex is -1
      _updateSection()

  # Push the last section if there was no new line at the
  # end of the file
  _updateSection()

  return allSections

#
# @chalk function
# @function
# @name format
# @description
# Format comment sections into readable format
# @param   {Array}  sections List of comment sections
# @param   {Object} options
# @returns {String} Formatted markdown code
#
format = (sections, options = {}) ->
  output = ""
  footer = ""
  for section, index in sections
    omitList = ["chalk"]

    # Skip through the rest of the sections
    break if options.header and index > 1

    # Skip through formatting private functions/variables
    continue if section.access? and (section.access is "private" and not options.private)

    if section.name?
      output += "\n"
      if index
        output += "#{section.name}"
        output += " (Deprecated)" if section.deprecated? and section.deprecated
        output += "\n---\n"
        omitList.push "deprecated"

      else
        if section.url?
          output += "[#{section.name}](#{section.url})" if section.url?
          omitList.push "url"
        else
          output += "#{section.name}"

        output +="\n==="

      output += "\n"
      omitList.push "name"

    if section.description?
      output += "#{section.description}  \n"
      omitList.push "description"

    if section.type?
      output += "Type: `#{section.type.join(", ")}`  \n\n"
      omitList.push "type"

    if section.version?
      output += "Version: `#{section.version}`  \n\n"
      omitList.push "version"

    if section.author? and not index
      footer += util.formatKeyValue "author", section.author, false, 2

      if section.email?
        footer += " (#{section.email})"
      footer += "\n"

    copyrightAndLicense =
      header:  []
      content: []

    if section.copyright? and not index
      copyrightAndLicense.header.push "copyright"
      copyrightAndLicense.content.push section.copyright

    if section.license? and not index
      copyrightAndLicense.header.push "license"
      copyrightAndLicense.content.push section.license

    if section.copyright? or section.license?
      footer += util.formatKeyValue copyrightAndLicense.header.join(" and "),
        copyrightAndLicense.content.join("\n\n"), true, 2

    # Copyright, license, email and author should only be parsed once
    omitList.push "copyright", "license", "author", "email"

    for key, value of _(section).omit omitList
      output += util.formatKeyValue(key, value)

  output += footer

  return output

#
# @chalk function
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
# @function
# @name write
# @description
# Write parsed content into the output file
# @param {String} source  File path of original file
# @param {String} content Content to write to file
# @param {Object} options
#
write = (source, content, options = {}) ->
  # Check if all the generated documentations are written to one file
  if options.join?
    output = lib.path.join cwd, options.join
    lib.fs.appendFileSync output, content
    return output

  # Check if output folder is specify
  else if options.output?
    base     = _(options.files).find (file) -> source.indexOf file is 0
    filename = lib.path.basename source, lib.path.extname(source)
    relative = lib.path.relative base, lib.path.dirname(source)
    filePath = lib.path.join(relative, filename) + ".md"
    output   = lib.path.join cwd, options.output, filePath
    dir      = lib.path.dirname output

    unless lib.fs.existsSync dir
      lib.wrench.mkdirSyncRecursive dir, 0o777

    lib.fs.writeFileSync output, content
    return output

  else
    console.log content

#
# @chalk function
# @function
# @name configure
# @description
# Configurate user options and validate file paths
# @param {Object} options User configurations
#
configure = (options) ->
  optsKeys = _(defaults).keys()
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

chalkboard = module.exports = {
  parse,
  compile,
  format,
  write,
  processFiles,
  configure
}
