(function() {
  var commentRegexStr, definitions, languages, path, util, _;

  path = require("path");

  _ = require("underscore");

  languages = require("../resources/languages.json");

  definitions = require("../resources/definitions/base.json");

  commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?";

  util = {
    capitalize: function(str) {
      if (str == null) {
        str = "";
      }
      if (!str) {
        return str;
      }
      return str[0].toUpperCase() + str.slice(1);
    },
    escape: function(text) {
      return text.replace(/[-[\]{}()*+?.,\\\/^$|#\s]/g, "\\$&");
    },
    repeatChar: function(char, count) {
      if (count == null) {
        count = 0;
      }
      return Array(count + 1).join(char);
    },
    getLanguages: function(source, options) {
      var ext, lang, regex, symbol;
      if (options == null) {
        options = {};
      }
      ext = path.extname(source) || path.basename(source);
      lang = languages[ext];
      if (lang == null) {
        return null;
      }
      symbol = util.escape(lang.symbol);
      regex = "^\\s*(?:" + symbol + "){1,2}" + commentRegexStr;
      lang.commentRegex = new RegExp(regex);
      lang.lineRegex = new RegExp("^\\s*(?:" + symbol + "){1,2}\\s+(.*)");
      if (lang.block != null) {
        lang.blockRegex = new RegExp(util.escape(lang.block));
      }
      if (lang.start != null) {
        lang.startRegex = new RegExp(util.escape(lang.start));
      }
      if (lang.end != null) {
        lang.endRegex = new RegExp(util.escape(lang.end));
      }
      return lang;
    },
    formatKeyValue: function(key, value, newLine, headerLevel) {
      var def, displayName, element, output, _i, _len;
      if (newLine == null) {
        newLine = true;
      }
      if (headerLevel == null) {
        headerLevel = 3;
      }
      def = definitions[key];
      displayName = (def != null ? def.displayName : void 0) != null ? def.displayName : key;
      output = util.repeatChar("#", headerLevel);
      output += " " + (util.capitalize(displayName)) + "\n";
      if (_(value).isArray()) {
        for (_i = 0, _len = value.length; _i < _len; _i++) {
          element = value[_i];
          if (_(element).isObject()) {
            if (element.name != null) {
              output += "**" + element.name + "**  \n";
            }
            if (element.type != null) {
              output += "Type: `" + element.type + "`  \n";
            }
            if ((element.description != null) && element.description) {
              output += "" + element.description + "  \n";
            }
          } else {
            output += "-   " + element + "  \n";
          }
        }
      } else if (_(value).isString()) {
        output += "" + value;
      }
      if (newLine) {
        output += "\n";
      }
      return output;
    }
  };

  module.exports = util;

}).call(this);
