chalkboard = require "../chalkboard.js"

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
    validSettings =
      name:         'coffeescript'
      symbol:       '#'
      block:        '###'
      commentRegex: /^\s*#{1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      blockRegex:   /###/

    test.deepEqual chalkboard._getLanguages("/test/test.coffee"), validSettings

    test.done()

  "Not supported language": (test) ->
    test.equal chalkboard._getLanguages("/test/test.fake"), null, "Should return null"
    test.done()