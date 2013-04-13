(function() {
  var Chalkboard, NEW_LINE, argsRegex, commentBlock, commentRegex, configure, defaults, definitions, format, fs, languages, marked, opts, parse, path, pkg, program, read, returnRegex, run, wrench, write, _, _capitalize, _formatKeyValue, _repeatChar, _setAttribute;

  program = require("commander");

  fs = require("fs");

  path = require("path");

  wrench = require("wrench");

  _ = require("underscore");

  marked = require("marked");

  pkg = require("./package.json");

  languages = require("./resources/languages.json");

  definitions = require("./resources/definitions.json");

  commentRegex = /^\s*#{1,2}\s*(?:@(\w+))?(?:\s*(.*))?/;

  argsRegex = /\{([\w\|]+)}\s([\w\d_-]+)\s(.*)/;

  commentBlock = /^\s*###\s*/;

  returnRegex = /\{([\w\|]+)}\s(.*)/;

  NEW_LINE = /\n\r?/;

  opts = {};

  defaults = {
    format: "markdown",
    output: null,
    join: null
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
    return Array(count + 1).join(char);
  };

  _setAttribute = function(object, key, value, options) {
    var _ref, _ref1;

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

  parse = function(code) {
    var allSections, argObject, argsMatch, currentSection, def, hasComment, key, line, match, matchingRegex, multiLineKey, newValue, value, _i, _len, _ref;

    hasComment = false;
    multiLineKey = "";
    allSections = [];
    currentSection = {};
    _ref = code.split(NEW_LINE);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      line = _ref[_i];
      if ((match = line.match(commentRegex))) {
        hasComment = true;
        key = match[1];
        value = match[2];
        if (key != null) {
          multiLineKey = "";
          def = definitions[key];
          if (def == null) {
            continue;
          }
          if ((def.hasArgs != null) && def.hasArgs) {
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
                type: argsMatch[1] || "undefined",
                description: argsMatch[3] || argsMatch[2]
              };
              if (argsMatch[3] != null) {
                argObject.name = argsMatch[2];
              }
              _setAttribute(currentSection, key, argObject, def);
            }
          } else if (def.multipleLines) {
            multiLineKey = key;
            if (value != null) {
              _setAttribute(currentSection, key, value, def);
            }
          } else if (def.typeIdentifier && (key != null)) {
            if (currentSection.type != null) {
              console.log("Cannot have multiple types. [Current: " + currentSection.type + "]");
            } else {
              currentSection.type = key;
            }
          } else if (def.accessIdentifier && (key != null)) {
            if (currentSection.access != null) {
              console.log("Cannot have multiple access specifier.");
            } else {
              currentSection.access = key;
            }
          } else {
            _setAttribute(currentSection, key, value, def);
          }
        }
        if (multiLineKey && (value != null)) {
          newValue = "" + value + "\n\n";
          _setAttribute(currentSection, multiLineKey, newValue, def);
        }
      } else {
        if (hasComment && !_(currentSection).isEmpty()) {
          allSections.push(currentSection);
          currentSection = {};
        }
        hasComment = false;
      }
    }
    return allSections;
  };

  _formatKeyValue = function(key, value, newLine, headerLevel) {
    var def, displayName, element, output, _i, _len;

    if (newLine == null) {
      newLine = true;
    }
    if (headerLevel == null) {
      headerLevel = 4;
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
            output += "**" + element.name + "**\n\n";
          }
          if (element.type != null) {
            output += "Type: `" + element.type + "`\n\n";
          }
          output += "" + element.description + "\n\n";
        } else {
          output += "-   " + element + "\n";
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

  format = function(sections) {
    var copyrightAndLicense, footer, index, key, omitList, output, section, value, _i, _len, _ref;

    output = "";
    footer = "";
    for (index = _i = 0, _len = sections.length; _i < _len; index = ++_i) {
      section = sections[index];
      omitList = [];
      if ((section.access != null) && section.access === "private") {
        continue;
      }
      if (section.name != null) {
        output += "\n";
        if (index) {
          output += "" + section.name + "\n---\n";
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
        output += "" + section.description + "\n";
        omitList.push("description");
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

  read = function(file, callback) {
    var relative, stat;

    stat = fs.existsSync(file) && fs.statSync(file);
    relative = path.relative(__dirname, file);
    if (stat && stat.isFile()) {
      return fs.readFile(file, function(error, buffer) {
        var content, data, parsedSections;

        if (error != null) {
          callback(error);
        }
        data = buffer.toString();
        parsedSections = parse(data);
        content = format(parsedSections);
        write(relative, content);
        return callback(relative);
      });
    } else if (stat && stat.isDirectory()) {

    } else {
      return callback("Invalid file path - " + file);
    }
  };

  write = function(source, content) {
    var dir, filePath, filename, output;

    if (program.join != null) {
      output = path.join(__dirname, program.join);
      return fs.appendFileSync(output, content);
    } else if (program.output != null) {
      filename = path.basename(source, path.extname(source));
      filePath = path.join(path.dirname(source), filename) + ".md";
      output = path.join(__dirname, program.output, filePath);
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
    opts = _.extend({}, defaults, _(options).pick(_(defaults).keys()));
    return console.log(opts);
  };

  run = function(argv) {
    var callback, doc, docPath, documents, fullPath, joinfilePath, stat, userFile, userFilesList, _i, _len, _ref, _results;

    if (argv == null) {
      argv = {};
    }
    program.version(pkg.version).usage("[options] [FILES...]").option("-o, --output [DIR]", "Documentation output file").option("-j, --join [FILE]", "Combine all documentation into one page").option("-f, --format [TYPE]", "Output format. Default to markdown").parse(argv);
    if (program.output && program.join) {
      console.error("Cannot use both output and join option at the same time");
      return process.exit(1);
    }
    if (program.join != null) {
      joinfilePath = path.join(__dirname, program.join);
      if (fs.existsSync(joinfilePath)) {
        fs.unlinkSync(joinfilePath);
      }
    }
    if ((_ref = program.format) == null) {
      program.format = "markdown";
    }
    callback = function(source, error) {
      if (error != null) {
        console.error(error);
        process.exit(1);
      }
      return console.log("Generated documentation for " + source);
    };
    userFilesList = program.args;
    if (userFilesList.length) {
      _results = [];
      for (_i = 0, _len = userFilesList.length; _i < _len; _i++) {
        userFile = userFilesList[_i];
        stat = fs.statSync(userFile);
        if (stat.isDirectory()) {
          documents = wrench.readdirSyncRecursive(userFile);
          documents = _(documents).chain().flatten().unique().value();
          _results.push((function() {
            var _j, _len1, _results1;

            _results1 = [];
            for (_j = 0, _len1 = documents.length; _j < _len1; _j++) {
              doc = documents[_j];
              docPath = path.join(__dirname, userFile, doc);
              _results1.push(read(docPath, callback));
            }
            return _results1;
          })());
        } else if (stat.isFile()) {
          fullPath = path.join(__dirname, userFile);
          _results.push(read(fullPath, callback));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    } else {
      return console.error(program.helpInformation());
    }
  };

  Chalkboard = module.exports = {
    parse: parse,
    run: run
  };

}).call(this);
