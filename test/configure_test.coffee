require "coffee-script/register"

chalkboard = require "../src/chalkboard"

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

    test.equal chalkboard.configure(options).output,
      "test/", "Setting output"

    options1 =
      output: "test/"
      format: "html"

    test.equal chalkboard.configure(options1).format,
      "html", "Setting format"

    options2 =
      output: "test/"
      args:   ["src/", "test/"]

    test.deepEqual chalkboard.configure(options2).files,
      ["src/", "test/"], "Setting args and files"

    test.done()
