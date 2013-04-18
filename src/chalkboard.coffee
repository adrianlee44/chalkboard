##
## @name Chalkboard.js
##
## @description
## An npm package that generate better documentation
##
## @author Adrian Lee
## @email adrian@radianstudio.com
## @copyright 2013 Adrian Lee
## @url https://github.com/adrianlee44/chalkboard
## @license MIT
##
## @dependencies
## - commander
## - wrench
## - marked
## - underscore
##
## @TODO
## [TODO Wiki](https://github.com/adrianlee44/chalkboard/wiki/TODO)
##

##
## @name Getting Started
## @description
## The easiest way to use chalkboard will probably be to install it globally.
##
## To do so, install the module with: `npm install -g chalkboard`
##

##
## @name Usage
## @description
##  Usage: chalkboard [options] [FILES...]
##  Options:
##    -h, --help           output usage information
##    -V, --version        output the version number
##    -o, --output [DIR]   Documentation output file
##    -j, --join [FILE]    Combine all documentation into one page
##    -f, --format [TYPE]  Output format. Default to markdown
##

program = require "commander"
fs      = require "fs"
path    = require "path"
wrench  = require "wrench"
_       = require "underscore"
marked  = require "marked"

pkg         = require "./package.json"
languages   = require "./resources/languages.json"
definitions = require "./resources/definitions.json"

commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?"
commentRegex    = new RegExp commentRegexStr
argsRegex       = /\{([\w\|]+)}\s([\w\d_-]+)\s?(.*)/
returnRegex     = /\{([\w\|]+)}\s?(.*)/
NEW_LINE        = /\n\r?/
cwd             = process.cwd()

defaults =
  format: "markdown"
  output: null
  join:   null

_capitalize = (str = "") ->
  return str unless str
  str[0].toUpperCase() + str[1..]

_repeatChar = (char, count = 0) ->
  Array(count+1).join char

_getLanguages = (source, options = {}) ->
  ext  = path.extname(source) or path.basename(source)
  lang = languages[ext]

  unless lang?
    throw new Error "Chalkboard does not support type #{ext}"

  regex = "^\\s*#{lang.symbol}{1,2}#{commentRegexStr}"
  lang.commentRegex = new RegExp regex
  lang.blockRegex   = new RegExp lang.block

  return lang

#
# @function
# @private
# @name _setAttribute
# @description
# Helper function for setting objects
# @param {Object} object Section object with information
# @param {String} key Name of the tag
# @param {String} value Value to be set
# @param {Object} options Tag definitions
# @returns {Number|String} Return the length of the array or value
#
_setAttribute = (object, key, value, options) ->
  if options.hasMultiple? and options.hasMultiple
    object[key] ?= []
    object[key].push value
  else
    object[key] ?= ""
    object[key] += value

#
# @function
# @name parse
# @description
# Run through code and parse out all the comments
# @param {String} code Source code to be parsed
# @param {Object} lang Language settings for the file
# @param {Object} options User settings
# @returns {Array} List of objects with all the comment block
#
parse = (code, lang, options = {})->
  hasComment     = false
  multiLineKey   = ""
  inCommentBlock = false

  allSections    = []
  currentSection = {}
  argObject      = {}

  for line in code.split(NEW_LINE)
    # Check for starting and ending comment block
    if (match = line.match lang.blockRegex)
      inCommentBlock = not inCommentBlock
      continue

    if (inCommentBlock and match = line.match commentRegex) or
        (match = line.match lang.commentRegex)

      hasComment = true
      key        = match[1]
      value      = match[2]

      if key?
        if multiLineKey and not _(argObject).isEmpty()
          do (multiLineKey, currentSection, argObject, definitions) ->
            keys = multiLineKey.split "."
            _setAttribute(currentSection,
              keys[0],
              argObject,
              definitions[keys[0]]
            )

          argObject = {}

        # Reset multiple line key since this is a new section
        multiLineKey = ""

        # Get the definition for the key
        def = definitions[key]
        continue unless def?

        hasArgs = def.hasArgs? and def.hasArgs

        # Identifier section
        # =====================

        # check if the current key is an type identifier
        if def.typeIdentifier and key?
          if currentSection.type?
            console.log """
              Cannot have multiple types. [Current: #{currentSection.type}]
            """
          else
            currentSection.type = key
            continue

        # check if the current key is an access identifier
        if def.accessIdentifier and key?
          if currentSection.access?
            console.log """
              Cannot have multiple access specifier.
            """
          else
            currentSection.access = key
            continue

        # For generic identifier
        value = true if def.identifier?

        # Following section is for tags with multiple arguments
        if hasArgs
          matchingRegex =
            switch key
              when "returns" then returnRegex
              else                argsRegex

          # Check value for arguments
          # Used by param and returns tag
          argsMatch = value.match matchingRegex
          if argsMatch?
            argObject =
              type: argsMatch[1] or "undefined"
            switch key
              when "param"
                argObject.description = argsMatch[3] or ""
                argObject.name        = argsMatch[2]
              when "returns"
                argObject.description = argsMatch[2] or ""

            value = null

        # when multiple lines are allowed, update the multiLineKey
        if def.multipleLines
          multiLineKey = if hasArgs then "#{key}.description" else key

        if value?
          _setAttribute currentSection, key, value, def

      # When key doesn't exist and multi line key is set,
      # add the value to the original key
      if multiLineKey and value?
        do (argObject, multiLineKey, value, currentSection, definitions) ->
          object = if _(argObject).isEmpty() then currentSection else argObject
          keys   = multiLineKey.split(".")
          _setAttribute(object,
            keys[keys.length - 1],
            "#{value}  \n",
            definitions[keys[keys.length - 1]]
          )

    else
      if hasComment and not _(currentSection).isEmpty()

        # Check if there is remaining argObject to be cleared
        if multiLineKey and not _(argObject).isEmpty()
          do (multiLineKey, currentSection, argObject, definitions) ->
            keys = multiLineKey.split "."
            _setAttribute(currentSection,
              keys[0],
              argObject,
              definitions[keys[0]]
            )

          multiLineKey = ""
          argObject    = {}

        allSections.push currentSection
        currentSection = {}

      hasComment = false

  return allSections

#
# @function
# @private
# @name _formatKeyValue
# @description
# Format value with type and description
# @param {String} key Tag name
# @param {String} value User input for the tag
# @param {Boolean} newLine If a new line should be appended to the end
# @param {Integer} headerLevel The header level of the section name
# @returns {String} Formatted markdown string based on key and value
#
_formatKeyValue = (key, value, newLine = true, headerLevel = 3) ->
  def         = definitions[key]
  displayName = if def?.displayName? then def.displayName else key

  output  = _repeatChar "#", headerLevel
  output += " #{_capitalize(displayName)}\n"
  if _(value).isArray()
    for element in value

      # returns and param
      if _(element).isObject()
        if element.name?
          output += "**#{element.name}**  \n"
        if element.type?
          output += "Type: `#{element.type}`  \n"
        if element.description? and element.description
          output += "#{element.description}  \n"

      # Everything else with just string
      else
        output += "-   #{element}  \n"

      output += "\n"

  else if _(value).isString()
    output += "#{value}"

  output += "\n" if newLine

  return output

#
# @function
# @name format
# @description
# Format comment sections into readable format
# @param {Array} sections List of comment sections
# @param {Object} options
# @returns {String} Formatted markdown code
#
format = (sections, options) ->
  output = ""
  footer = ""
  for section, index in sections
    omitList = []

    continue if section.access? and section.access is "private"

    isDeprecated = section.deprecated?

    if section.name?
      output += "\n"
      if index
        output += "#{section.name}"
        output += " (Deprecated)" if isDeprecated
        output += "\n---\n"

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
      output += "#{section.description}\n"
      omitList.push "description"

    if section.type?
      output += "Type: `#{section.type}`  \n\n"
      omitList.push "type"

    if section.version?
      output += "Version: `#{section.version}`  \n\n"
      omitList.push "version"

    if section.author? and not index
      footer += _formatKeyValue "author", section.author, false, 2

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
      footer += _formatKeyValue copyrightAndLicense.header.join(" and "),
        copyrightAndLicense.content.join("\n\n"), true, 2

    # Copyright, license, email and author should only be parsed once
    omitList.push "copyright", "license", "author", "email"

    for key, value of _(section).omit omitList
      output += _formatKeyValue(key, value)

  output += footer

  return output

#
# @function
# @name read
# @description
# Read the content of the file
# @param {String} file File path
# @param {Object} options User options
# @param {Function} callback Read callback
# @returns {Boolean} File has been read successfully
#
read = (file, options = {}, callback) ->
  stat     = fs.existsSync(file) && fs.statSync(file)
  relative = path.relative cwd, file

  if stat and stat.isFile()
    lang = _getLanguages file, options

    fs.readFile file, (error, buffer) ->
      callback error if error?

      data           = buffer.toString()
      parsedSections = parse data, lang, options
      content        = format parsedSections, options
      write relative, content, options
      callback? relative

  else if stat and stat.isDirectory()
    # do nothing

  else
    callback? "Invalid file path - #{file}"

#
# @function
# @name write
# @description
# Write parsed content into the output file
# @param {String} source File path of original file
# @param {String} content Content to write to file
# @param {Object} options
#
write = (source, content, options = {}) ->
  # Check if all the generated documentations are written to one file
  if options.join?
    output = path.join cwd, options.join
    fs.appendFileSync output, content

  # Check if output folder is specify
  else if options.output?
    filename = path.basename source, path.extname(source)
    filePath = path.join(path.dirname(source), filename) + ".md"
    output   = path.join cwd, options.output, filePath
    dir      = path.dirname output

    unless fs.existsSync dir
      wrench.mkdirSyncRecursive dir, 0o777

    fs.writeFileSync output, content

  else
    console.log content

configure = (options) ->
  opts = _.extend {}, defaults, _(options).pick(_(defaults).keys())

  if opts.output and opts.join
    throw new Error "Cannot use both output and join option at the same time"

  # clean the existing file if all comments are compiled to one location
  if opts.join?
    joinfilePath = path.join cwd, opts.join

    # Clear the original file by write empty string into it
    fs.unlinkSync(joinfilePath) if fs.existsSync joinfilePath

  opts.files = options.args or []

  return opts

processFiles = (options)->
  opts = configure options

  callback = (source, error) ->
    throw new Error(error) if error?

    console.log "Generated documentation for #{source}"

  for userFile in opts.files
    stat = fs.statSync userFile

    if stat.isDirectory()
      documents = wrench.readdirSyncRecursive userFile
      documents = _(documents).chain()
                    .flatten()
                    .unique()
                    .value()

      for doc in documents
        docPath = path.join cwd, userFile, doc
        read docPath, opts, callback

    else if stat.isFile()
      fullPath = path.join cwd, userFile
      read fullPath, opts, callback

#
# @function
# @name run
# @description
# Start the process of generating documentation with source code
# @param {Array} argv List of arguments
#
run = (argv = {})->
  program
    .version(pkg.version)
    .usage("[options] [FILES...]")
    .option("-o, --output [DIR]", "Documentation output file")
    .option("-j, --join [FILE]", "Combine all documentation into one page")
    .option("-f, --format [TYPE]", "Output format. Default to markdown")
    .parse argv

  if program.args.length
    processFiles program
  else
    console.log program.helpInformation()

Chalkboard = module.exports = {
  _capitalize,
  _repeatChar,
  _getLanguages,
  parse,
  run,
  read,
  write,
  processFiles,
  configure
}
