
/*
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
 *
 * @chalk overview
 * @name example
 * @description
 * This is an example description for an example in readme.
 * @param {String} name Just a random name
 * @param {Boolean} work Does this actually work?
 * @returns {String} Just another value
 *
```

@TODO
[TODO Wiki](https://github.com/adrianlee44/chalkboard/wiki/TODO)
 */


/*
@chalk overview
@name Supported Tags
@description
[Wiki Page](https://github.com/adrianlee44/chalkboard/wiki/Supported-Tags)
 */


/*
@chalk overview
@name Getting Started
@description
The easiest way to use chalkboard will probably be to install it globally.

To do so, install the module with:
```
npm install -g chalkboard
```
 */


/*
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
 */

(function() {
  var NEW_LINE, chalkboard, commentRegex, compile, configure, cwd, defaults, definitions, format, languages, lib, packages, parse, pkg, processFiles, requirePkg, util, write, _, _i, _len;

  util = require("./lib/util");

  pkg = require("./package.json");

  languages = require("./resources/languages.json");

  definitions = require("./resources/definitions/base.json");

  packages = ["fs", "path", "wrench", "marked"];

  lib = {};

  for (_i = 0, _len = packages.length; _i < _len; _i++) {
    requirePkg = packages[_i];
    lib[requirePkg] = require(requirePkg);
  }

  _ = require("underscore");

  commentRegex = /^\s*@(\w+)(?:\s*(.*))?$/;

  NEW_LINE = /\n\r?/;

  cwd = process.cwd();

  defaults = {
    format: "markdown",
    output: null,
    join: null,
    header: false,
    "private": false
  };

  parse = function(code, lang, options) {
    var allSections, argObject, argsMatch, blockRegex, commentBlockIndex, content, currentSection, def, hasArgs, hasComment, key, line, lnMatch, match, matchingRegex, multiLineKey, setValue, toMatchRegex, type, value, _getMultiLineKey, _j, _len1, _multiLineSetAttribute, _ref, _setArgObject, _setAttribute, _updateSection;
    if (options == null) {
      options = {};
    }
    hasComment = false;
    multiLineKey = "";
    commentBlockIndex = -1;
    allSections = [];
    currentSection = {};
    argObject = {};
    _setAttribute = function(object, key, value, options) {
      if (options == null) {
        options = {};
      }
      if ((options.hasMultiple != null) && options.hasMultiple) {
        if (object[key] == null) {
          object[key] = [];
        }
        return object[key].push(value);
      } else {
        if (object[key] == null) {
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
      value += "  \n";
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
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      line = _ref[_j];
      blockRegex = commentBlockIndex > -1 ? lang.endRegex : lang.startRegex;
      if (match = line.match(blockRegex || lang.blockRegex)) {
        commentBlockIndex = commentBlockIndex > -1 ? -1 : match.index;
        if (commentBlockIndex === -1) {
          _updateSection();
        }
        continue;
      }
      toMatchRegex = commentBlockIndex > -1 ? commentRegex : lang.commentRegex;
      if (match = line.match(toMatchRegex)) {
        key = match[1];
        value = match[2];
        if (key === "chalk") {
          _updateSection();
          hasComment = true;
          currentSection.chalk = value;
          continue;
        }
        if (!hasComment) {
          continue;
        }
        def = definitions[key];
        if ((key != null) && (def != null)) {
          _setArgObject();
          hasArgs = (def.hasArgs != null) && def.hasArgs;
          if (def.typeIdentifier && (key != null)) {
            type = value ? value : key;
            if (currentSection.type != null) {
              currentSection.type.push(type);
            } else {
              currentSection.type = [key];
              continue;
            }
          }
          if (def.accessIdentifier && (key != null)) {
            if (currentSection.access != null) {
              console.log("Cannot have multiple access specifier.");
            } else {
              currentSection.access = key === "access" ? value : key;
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
                  return /\{([\w\|]+)}(?:\s+(.*))?/;
                default:
                  return /\{([\w\|\s]+)}\s+([\w\d_-]+)(?:\s+(.*))?/;
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
          continue;
        }
        setValue = (key != null) && (def == null) ? line : value;
        if (multiLineKey && (setValue != null)) {
          _multiLineSetAttribute(setValue);
        }
      } else if (multiLineKey && ((lnMatch = line.match(lang.lineRegex)) || commentBlockIndex > -1)) {
        line = line.substr(commentBlockIndex);
        content = commentBlockIndex > -1 ? line : (lnMatch != null ? lnMatch[1] : void 0) || line;
        _multiLineSetAttribute(content);
      } else if (commentBlockIndex === -1) {
        _updateSection();
      }
    }
    _updateSection();
    return allSections;
  };

  format = function(sections, options) {
    var copyrightAndLicense, footer, index, key, omitList, output, section, value, _j, _len1, _ref;
    if (options == null) {
      options = {};
    }
    output = "";
    footer = "";
    for (index = _j = 0, _len1 = sections.length; _j < _len1; index = ++_j) {
      section = sections[index];
      omitList = ["chalk"];
      if (options.header && index > 1) {
        break;
      }
      if ((section.access != null) && (section.access === "private" && !options["private"])) {
        continue;
      }
      if (section.name != null) {
        output += "\n";
        if (index) {
          output += "" + section.name;
          if ((section.deprecated != null) && section.deprecated) {
            output += " (Deprecated)";
          }
          output += "\n---\n";
          omitList.push("deprecated");
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
        output += "Type: `" + (section.type.join(", ")) + "`  \n\n";
        omitList.push("type");
      }
      if (section.version != null) {
        output += "Version: `" + section.version + "`  \n\n";
        omitList.push("version");
      }
      if ((section.author != null) && !index) {
        footer += util.formatKeyValue("author", section.author, false, 2);
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
        footer += util.formatKeyValue(copyrightAndLicense.header.join(" and "), copyrightAndLicense.content.join("\n\n"), true, 2);
      }
      omitList.push("copyright", "license", "author", "email");
      _ref = _(section).omit(omitList);
      for (key in _ref) {
        value = _ref[key];
        output += util.formatKeyValue(key, value);
      }
    }
    output += footer;
    return output;
  };

  compile = function(code, options, filepath) {
    var formatted, lang, parsed;
    if (options == null) {
      options = {};
    }
    if (filepath == null) {
      return;
    }
    lang = util.getLanguages(filepath, options);
    if (lang == null) {
      return null;
    }
    parsed = parse(code, lang, options);
    formatted = format(parsed, options);
    if (options.format === "html") {
      formatted = lib.marked(formatted);
    }
    return formatted;
  };

  write = function(source, content, options) {
    var base, dir, filePath, filename, output, relative;
    if (options == null) {
      options = {};
    }
    if (options.join != null) {
      output = lib.path.join(cwd, options.join);
      lib.fs.appendFileSync(output, content);
      return output;
    } else if (options.output != null) {
      base = _(options.files).find(function(file) {
        return source.indexOf(file === 0);
      });
      filename = lib.path.basename(source, lib.path.extname(source));
      relative = lib.path.relative(base, lib.path.dirname(source));
      filePath = lib.path.join(relative, filename) + ".md";
      output = lib.path.join(cwd, options.output, filePath);
      dir = lib.path.dirname(output);
      if (!lib.fs.existsSync(dir)) {
        lib.wrench.mkdirSyncRecursive(dir, 0x1ff);
      }
      lib.fs.writeFileSync(output, content);
      return output;
    } else {
      return console.log(content);
    }
  };

  configure = function(options) {
    var joinfilePath, opts, optsKeys;
    optsKeys = _(defaults).keys();
    opts = _.extend({}, defaults, _.pick(options, optsKeys));
    if (opts.output && opts.join) {
      throw new Error("Cannot use both output and join option at the same time");
    }
    if (opts.join != null) {
      joinfilePath = lib.path.join(cwd, opts.join);
      if (lib.fs.existsSync(joinfilePath)) {
        lib.fs.unlinkSync(joinfilePath);
      }
    }
    opts.files = options.args || [];
    return opts;
  };

  processFiles = function(options) {
    var doc, docPath, documents, findAll, opts, process, stat, userFile, _j, _len1, _ref, _results;
    opts = configure(options);
    process = function(path) {
      return lib.fs.readFile(path, function(error, buffer) {
        var formatted, readFilename, relative, source, writeFile;
        if (error != null) {
          throw new Error(error);
        }
        source = buffer.toString();
        formatted = compile(source, opts, path);
        if (formatted) {
          relative = lib.path.relative(cwd, path);
          writeFile = write(relative, formatted, opts);
        }
        readFilename = lib.path.basename(path);
        return console.log("Generated documentation for \"" + readFilename + "\".");
      });
    };
    _ref = opts.files;
    _results = [];
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      userFile = _ref[_j];
      stat = lib.fs.statSync(userFile);
      if (stat.isDirectory()) {
        documents = lib.wrench.readdirSyncRecursive(userFile);
        findAll = _.compose(_.unique, _.flatten);
        documents = findAll(documents);
        _results.push((function() {
          var _k, _len2, _results1;
          _results1 = [];
          for (_k = 0, _len2 = documents.length; _k < _len2; _k++) {
            doc = documents[_k];
            docPath = lib.path.join(cwd, userFile, doc);
            stat = lib.fs.existsSync(docPath) && lib.fs.statSync(docPath);
            if (stat.isFile()) {
              _results1.push(process(docPath));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      } else if (stat.isFile()) {
        _results.push(process(lib.path.join(cwd, userFile)));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  chalkboard = module.exports = {
    parse: parse,
    compile: compile,
    format: format,
    write: write,
    processFiles: processFiles,
    configure: configure
  };

}).call(this);
