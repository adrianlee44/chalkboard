chalkboard = require "../chalkboard.js"

exports.configureTest =
  "Both output and join are set": (test) ->
    options =
      output: "test/"
      join:   "test.md"

    errorMsg = "Cannot use both output and join option at the same time"
    test.throws ->
      chalkboard.configure(options)
      return true
    , Error, errorMsg
    test.done()

  "Test if extending options is working": (test) ->
    test.expect 3

    options =
      output: "test/"

    outputOptions =
      format: "markdown"
      output: "test/"
      join:   null
      files:  []

    test.deepEqual chalkboard.configure(options),
      outputOptions,
      "Setting output"

    options1 =
      output: "test/"
      format: "html"

    outputOptions1 =
      format: "html"
      output: "test/"
      join:   null
      files:  []

    test.deepEqual chalkboard.configure(options1),
      outputOptions1,
      "Setting format"

    options2 =
      output: "test/"
      args:   ["src/", "test/"]

    outputOptions2 =
      format: "markdown"
      output: "test/"
      join:   null
      files:  ["src/", "test/"]

    test.deepEqual chalkboard.configure(options2),
      outputOptions2,
      "Setting args and files"

    test.done()

exports.utilTest =
  "Capitalize Test": (test) ->
    test.equal chalkboard._capitalize("test"), "Test"
    test.done()

  "Empty String": (test) ->
    test.equal chalkboard._capitalize(""), ""
    test.done()

  "Repeat Char Test": (test) ->
    test.equal chalkboard._repeatChar("#", 3), "###"
    test.done()

  "Repeat Char No Count Test": (test) ->
    test.equal chalkboard._repeatChar("#"), ""
    test.done()

  "Get languages test for Coffee": (test) ->
    languages = require "../resources/languages.json"

    validSettings =
      name:         'coffeescript'
      symbol:       '#'
      block:        '###'
      commentRegex: /^\s*#{1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      blockRegex:   /###/

    test.deepEqual chalkboard._getLanguages("/test/test.coffee"), validSettings

    test.done()