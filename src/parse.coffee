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

definitions = require "../resources/definitions/base.json"
_           = require "lodash"

commentRegex = /^\s*@(\w+)(?:\s*(.*))?$/
NEW_LINE     = /\n\r?/

module.exports = (code, lang, options = {})->
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
    object = if _.isEmpty(argObject) then currentSection else argObject
    value += "  \n"
    _setAttribute(object,
      _getMultiLineKey(-1),
      value,
      definitions[_getMultiLineKey(-1)]
    )

  _setArgObject = ->
    if multiLineKey and not _.isEmpty(argObject)
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
    if hasComment and not _.isEmpty(currentSection)

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
