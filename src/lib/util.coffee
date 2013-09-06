path            = require "path"
languages       = require "../resources/languages.json"
commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?"

#
# @function
# @name _captialize
# @description
# Capitalize the first letter of a string
# @param {String} str String to be capitalized
# @returns {String} Capitalized string
#
_capitalize = (str = "") ->
  return str unless str
  str[0].toUpperCase() + str[1..]

#
# @function
# @nam _repeatChar
# @description
# Repeat a character multiple times
# @param {Sting} char Character to repeat
# @param {Integer} count Number of times to repeat the character
# @returns {String} Processed string
#
_repeatChar = (char, count = 0) ->
  Array(count+1).join char

_getLanguages = (source, options = {}) ->
  ext  = path.extname(source) or path.basename(source)
  lang = languages[ext]

  # Should fail silently when langauge is not supported
  # and move onto the next file
  return null unless lang?

  regex = "^\\s*(?:#{lang.symbol}){1,2}#{commentRegexStr}"
  lang.commentRegex = new RegExp regex
  lang.lineRegex    = new RegExp "^\\s*(?:#{lang.symbol}){1,2}\\s+(.*)"
  lang.blockRegex   = new RegExp lang.block

  lang.startRegex = new RegExp lang.start if lang.start?
  lang.endRegex   = new RegExp lang.end   if lang.end?

  return lang

module.exports = {
  _capitalize
  _repeatChar
  _getLanguages
}