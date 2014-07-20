require "coffee-script/register"

util = require "../src/lib/util"

exports.utilTest =
  "Capitalize Test": (test) ->
    test.equal util.capitalize("test"), "Test"
    test.done()

  "Empty String": (test) ->
    test.equal util.capitalize(""), ""
    test.done()

  "Repeat Char Test": (test) ->
    test.equal util.repeatChar("#", 3), "###"
    test.done()

  "Repeat Char No Count Test": (test) ->
    test.equal util.repeatChar("#"), ""
    test.done()

  "Get languages test for Coffee": (test) ->
    validSettings =
      name:         'coffeescript'
      symbol:       '#'
      block:        '###'
      lineRegex:    /^\s*(?:\#){1,2}\s+(.*)/
      commentRegex: /^\s*(?:\#){1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      blockRegex:   /\#\#\#/

    test.deepEqual util.getLanguages("/test/test.coffee"), validSettings

    test.done()

  "Get languages test for Javascript": (test) ->
    validSettings =
      name:         'javascript'
      symbol:       '//'
      start:        '/*'
      end:          '*/'
      lineRegex:    /^\s*(?:\/\/){1,2}\s+(.*)/
      commentRegex: /^\s*(?:\/\/){1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      startRegex:   /\/\*/
      endRegex:     /\*\//

    test.deepEqual util.getLanguages("/test/test.js"), validSettings

    test.done()

  "Not supported language": (test) ->
    test.equal util.getLanguages("/test/test.fake"), null, "Should return null"
    test.done()

  "Default formatKeyValue with string value": (test) ->
    output = util.formatKeyValue "name", "testing"
    test.equal output, "### Name\ntesting\n"
    test.done()

  "formatKeyValue with string value with no new line": (test) ->
    output = util.formatKeyValue "name", "testing", false
    test.equal output, "### Name\ntesting"
    test.done()

  "formatKeyValue with string value with header level 1": (test) ->
    output = util.formatKeyValue "name", "testing", true, 1
    test.equal output, "# Name\ntesting\n"
    test.done()

  "formatKeyValue with an array": (test) ->
    output = util.formatKeyValue "list", [
      "item1"
      "item2"
    ]
    test.equal output, "### List\n-   item1  \n-   item2  \n\n"
    test.done()

  "formatKeyValue with an array of object": (test) ->
    output = util.formatKeyValue "list", [
      {name: "Chalk", type: "Item", description: "Writing tool"}
    ]

    test.equal output, """
      ### List
      **Chalk**  \nType: `Item`  \nWriting tool  \n\n
    """
    test.done()
