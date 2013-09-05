(function() {
  var commentRegexStr, languages, path, _capitalize, _getLanguages, _repeatChar;

  path = require("path");

  languages = require("../resources/languages.json");

  commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?";

  _capitalize = function(str) {
    if (str == null) {
      str = "";
    }
    if (!str) {
      return str;
    }
    return str[0].toUpperCase() + str.slice(1);
  };

  _repeatChar = function(char, count) {
    if (count == null) {
      count = 0;
    }
    return Array(count + 1).join(char);
  };

  _getLanguages = function(source, options) {
    var ext, lang, regex;
    if (options == null) {
      options = {};
    }
    ext = path.extname(source) || path.basename(source);
    lang = languages[ext];
    if (lang == null) {
      return null;
    }
    regex = "^\\s*(?:" + lang.symbol + "){1,2}" + commentRegexStr;
    lang.commentRegex = new RegExp(regex);
    lang.lineRegex = new RegExp("^\\s*(?:" + lang.symbol + "){1,2}\\s+(.*)");
    lang.blockRegex = new RegExp(lang.block);
    if (lang.start != null) {
      lang.startRegex = new RegExp(lang.start);
    }
    if (lang.end != null) {
      lang.endRegex = new RegExp(lang.end);
    }
    return lang;
  };

  module.exports = {
    _capitalize: _capitalize,
    _repeatChar: _repeatChar,
    _getLanguages: _getLanguages
  };

}).call(this);
