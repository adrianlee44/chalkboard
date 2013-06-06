(function() {
  var NEW_LINE, argsRegex, chalkboard, commentRegex, commentRegexStr, compile, configure, cwd, defaults, definitions, format, fs, languages, lnValueRegexStr, marked, parse, path, pkg, processFiles, program, read, returnRegex, run, wrench, write, _, _capitalize, _formatKeyValue, _getLanguages, _repeatChar;

  program = require("commander");

  fs = require("fs");

  path = require("path");

  wrench = require("wrench");

  _ = require("underscore");

  marked = require("marked");

  pkg = require("./package.json");

  languages = require("./resources/languages.json");

  definitions = require("./resources/definitions.json");

  commentRegexStr = "\\s*(?:@(\\w+))?(?:\\s*(.*))?";

  lnValueRegexStr = "\\s*(.*)";

  commentRegex = new RegExp(commentRegexStr);

  argsRegex = /\{([\w\|\s]+)}\s+([\w\d_-]+)(?:\s+(.*))?/;

  returnRegex = /\{([\w\|]+)}(?:\s+(.*))?/;

  NEW_LINE = /\n\r?/;

  cwd = process.cwd();

  defaults = {
    format: "markdown",
    output: null,
    join: null,
    header: false,
    "private": false
  };

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
    regex = "^\\s*" + lang.symbol + "{1,2}" + commentRegexStr;
    lang.commentRegex = new RegExp(regex);
    lang.lineRegex = new RegExp("^\\s*" + lang.symbol + "{1,2}\\s+(.*)");
    lang.blockRegex = new RegExp(lang.block);
    return lang;
  };

  parse = function(code, lang, options) {
    var allSections, argObject, argsMatch, currentSection, def, hasArgs, hasComment, inCommentBlock, key, line, lnMatch, match, matchingRegex, multiLineKey, toMatchRegex, value, _getMultiLineKey, _i, _len, _multiLineSetAttribute, _ref, _setArgObject, _setAttribute, _updateSection;

    if (options == null) {
      options = {};
    }
    hasComment = false;
    multiLineKey = "";
    inCommentBlock = false;
    allSections = [];
    currentSection = {};
    argObject = {};
    _setAttribute = function(object, key, value, options) {
      var _ref, _ref1;

      if (options == null) {
        options = {};
      }
      if ((options.hasMultiple != null) && options.hasMultiple) {
        if ((_ref = object[key]) == null) {
          object[key] = [];
        }
        return object[key].push(value);
      } else {
        if ((_ref1 = object[key]) == null) {
          object[key] = "";
        }
        return object[key] += value;
      }
    };
    _getMultiLineKey = function(index) {
      var keys;

      keys = multiLineKey.split(".");
      if (index < 0) {
        index = keys.length + index;
      }
      if (keys.length === 0 || index < 0 || index > keys.length) {
        return "";
      }
      return keys[index];
    };
    _multiLineSetAttribute = function(value) {
      var object;

      object = _(argObject).isEmpty() ? currentSection : argObject;
      if (value) {
        value += "  \n";
      }
      return _setAttribute(object, _getMultiLineKey(-1), value, definitions[_getMultiLineKey(-1)]);
    };
    _setArgObject = function() {
      if (multiLineKey && !_(argObject).isEmpty()) {
        _setAttribute(currentSection, _getMultiLineKey(0), argObject, definitions[_getMultiLineKey(0)]);
      }
      argObject = {};
      return multiLineKey = "";
    };
    _updateSection = function() {
      if (hasComment && !_(currentSection).isEmpty()) {
        _setArgObject();
        allSections.push(currentSection);
        currentSection = {};
      }
      return hasComment = false;
    };
    _ref = code.split(NEW_LINE);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      if (line.match(lang.blockRegex)) {
        inCommentBlock = !inCommentBlock;
        if (!inCommentBlock) {
          _updateSection();
        }
        continue;
      }
      toMatchRegex = inCommentBlock ? commentRegex : lang.commentRegex;
      if (match = line.match(toMatchRegex)) {
        key = match[1];
        value = match[2];
        if (key === "chalk") {
          hasComment = true;
          currentSection.chalk = value;
          continue;
        }
        if (!hasComment) {
          continue;
        }
        if (key != null) {
          _setArgObject();
          def = definitions[key];
          if (def == null) {
            continue;
          }
          hasArgs = (def.hasArgs != null) && def.hasArgs;
          if (def.typeIdentifier && (key != null)) {
            if (currentSection.type != null) {
              console.log("Cannot have multiple types. [Current: " + currentSection.type + "]");
            } else {
              currentSection.type = key;
              continue;
            }
          }
          if (def.accessIdentifier && (key != null)) {
            if (currentSection.access != null) {
              console.log("Cannot have multiple access specifier.");
            } else {
              currentSection.access = key;
              continue;
            }
          }
          if (def.identifier != null) {
            value = true;
          }
          if (hasArgs) {
            matchingRegex = (function() {
              switch (key) {
                case "returns":
                  return returnRegex;
                default:
                  return argsRegex;
              }
            })();
            argsMatch = value.match(matchingRegex);
            if (argsMatch != null) {
              argObject = {
                type: argsMatch[1] || "undefined"
              };
              switch (key) {
                case "param":
                  argObject.description = argsMatch[3] || "";
                  argObject.name = argsMatch[2];
                  break;
                case "returns":
                  argObject.description = argsMatch[2] || "";
              }
              if (argObject.description) {
                argObject.description += "  \n";
              }
              value = null;
            }
          }
          if (def.multipleLines) {
            multiLineKey = hasArgs ? "" + key + ".description" : key;
          }
          if (value != null) {
            _setAttribute(currentSection, key, value, def);
          }
        }
        if (multiLineKey && (value != null)) {
          _multiLineSetAttribute(value);
        }
      } else if (multiLineKey && ((lnMatch = line.match(lang.lineRegex)) || inCommentBlock)) {
        _multiLineSetAttribute((lnMatch != null ? lnMatch[1] : void 0) || line);
      } else {
        _updateSection();
      }
    }
    _updateSection();
    return allSections;
  };

  _formatKeyValue = function(key, value, newLine, headerLevel) {
    var def, displayName, element, output, _i, _len;

    if (newLine == null) {
      newLine = true;
    }
    if (headerLevel == null) {
      headerLevel = 3;
    }
    def = definitions[key];
    displayName = (def != null ? def.displayName : void 0) != null ? def.displayName : key;
    output = _repeatChar("#", headerLevel);
    output += " " + (_capitalize(displayName)) + "\n";
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
  };

  format = function(sections, options) {
    var copyrightAndLicense, footer, index, isDeprecated, key, omitList, output, section, value, _i, _len, _ref;

    output = "";
    footer = "";
    for (index = _i = 0, _len = sections.length; _i < _len; index = ++_i) {
      section = sections[index];
      omitList = ["chalk"];
      if (options.header && index > 1) {
        break;
      }
      if ((section.access != null) && (section.access === "private" && !options["private"])) {
        continue;
      }
      isDeprecated = section.deprecated != null;
      if (section.name != null) {
        output += "\n";
        if (index) {
          output += "" + section.name;
          if (isDeprecated) {
            output += " (Deprecated)";
          }
          output += "\n---\n";
        } else {
          if (section.url != null) {
            if (section.url != null) {
              output += "[" + section.name + "](" + section.url + ")";
            }
            omitList.push("url");
          } else {
            output += "" + section.name;
          }
          output += "\n===";
        }
        output += "\n";
        omitList.push("name");
      }
      if (section.description != null) {
        output += "" + section.description + "  \n";
        omitList.push("description");
      }
      if (section.type != null) {
        output += "Type: `" + section.type + "`  \n\n";
        omitList.push("type");
      }
      if (section.version != null) {
        output += "Version: `" + section.version + "`  \n\n";
        omitList.push("version");
      }
      if ((section.author != null) && !index) {
        footer += _formatKeyValue("author", section.author, false, 2);
        if (section.email != null) {
          footer += " (" + section.email + ")";
        }
        footer += "\n";
      }
      copyrightAndLicense = {
        header: [],
        content: []
      };
      if ((section.copyright != null) && !index) {
        copyrightAndLicense.header.push("copyright");
        copyrightAndLicense.content.push(section.copyright);
      }
      if ((section.license != null) && !index) {
        copyrightAndLicense.header.push("license");
        copyrightAndLicense.content.push(section.license);
      }
      if ((section.copyright != null) || (section.license != null)) {
        footer += _formatKeyValue(copyrightAndLicense.header.join(" and "), copyrightAndLicense.content.join("\n\n"), true, 2);
      }
      omitList.push("copyright", "license", "author", "email");
      _ref = _(section).omit(omitList);
      for (key in _ref) {
        value = _ref[key];
        output += _formatKeyValue(key, value);
      }
    }
    output += footer;
    return output;
  };

  compile = function(code, options, filepath) {
    var lang, parsed;

    if (options == null) {
      options = {};
    }
    if (filepath == null) {
      return;
    }
    lang = _getLanguages(filepath, options);
    if (lang == null) {
      return null;
    }
    parsed = parse(code, lang, options);
    return format(parsed, options);
  };

  read = function(file, options, callback) {
    var lang, relative, stat;

    if (options == null) {
      options = {};
    }
    stat = fs.existsSync(file) && fs.statSync(file);
    relative = path.relative(cwd, file);
    if (stat && stat.isFile()) {
      lang = _getLanguages(file, options);
      if (lang == null) {
        return;
      }
      return fs.readFile(file, function(error, buffer) {
        var content, data, parsedSections;

        if (error != null) {
          callback(error);
        }
        data = buffer.toString();
        parsedSections = parse(data, lang, options);
        content = format(parsedSections, options);
        if (content) {
          write(relative, content, options);
          return typeof callback === "function" ? callback(relative) : void 0;
        }
      });
    } else if (stat && stat.isDirectory()) {

    } else {
      return typeof callback === "function" ? callback("Invalid file path - " + file) : void 0;
    }
  };

  write = function(source, content, options) {
    var base, dir, filePath, filename, output, relative;

    if (options == null) {
      options = {};
    }
    if (options.format === "html") {
      content = marked(content);
    }
    if (options.join != null) {
      output = path.join(cwd, options.join);
      return fs.appendFileSync(output, content);
    } else if (options.output != null) {
      base = _(options.files).find(function(file) {
        return source.indexOf(file === 0);
      });
      filename = path.basename(source, path.extname(source));
      relative = path.relative(base, path.dirname(source));
      filePath = path.join(relative, filename) + ".md";
      output = path.join(cwd, options.output, filePath);
      dir = path.dirname(output);
      if (!fs.existsSync(dir)) {
        wrench.mkdirSyncRecursive(dir, 0x1ff);
      }
      return fs.writeFileSync(output, content);
    } else {
      return console.log(content);
    }
  };

  configure = function(options) {
    var joinfilePath, opts;

    opts = _.extend({}, defaults, _(options).pick(_(defaults).keys()));
    if (opts.output && opts.join) {
      throw new Error("Cannot use both output and join option at the same time");
    }
    if (opts.join != null) {
      joinfilePath = path.join(cwd, opts.join);
      if (fs.existsSync(joinfilePath)) {
        fs.unlinkSync(joinfilePath);
      }
    }
    opts.files = options.args || [];
    return opts;
  };

  processFiles = function(options) {
    var callback, doc, docPath, documents, fullPath, opts, stat, userFile, _i, _len, _ref, _results;

    opts = configure(options);
    callback = function(source, error) {
      if (error != null) {
        throw new Error(error);
      }
      return console.log("Generated documentation for " + source);
    };
    _ref = opts.files;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      userFile = _ref[_i];
      stat = fs.statSync(userFile);
      if (stat.isDirectory()) {
        documents = wrench.readdirSyncRecursive(userFile);
        documents = _(documents).chain().flatten().unique().value();
        _results.push((function() {
          var _j, _len1, _results1;

          _results1 = [];
          for (_j = 0, _len1 = documents.length; _j < _len1; _j++) {
            doc = documents[_j];
            docPath = path.join(cwd, userFile, doc);
            _results1.push(read(docPath, opts, callback));
          }
          return _results1;
        })());
      } else if (stat.isFile()) {
        fullPath = path.join(cwd, userFile);
        _results.push(read(fullPath, opts, callback));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  run = function(argv) {
    if (argv == null) {
      argv = {};
    }
    program.version(pkg.version).usage("[options] [FILES...]").option("-o, --output [DIR]", "Documentation output file").option("-j, --join [FILE]", "Combine all documentation into one page").option("-f, --format [TYPE]", "Output format. Default to markdown (markdown | html)").option("-p, --private", "Parse comments for private functions and variables").option("-h, --header", "Only parse the first comment block").parse(argv);
    if (program.args.length) {
      return processFiles(program);
    } else {
      return console.log(program.helpInformation());
    }
  };

  chalkboard = module.exports = {
    _capitalize: _capitalize,
    _repeatChar: _repeatChar,
    _getLanguages: _getLanguages,
    parse: parse,
    run: run,
    compile: compile,
    format: format,
    read: read,
    write: write,
    processFiles: processFiles,
    configure: configure
  };

}).call(this);
