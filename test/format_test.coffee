chalkboard = require "../chalkboard.js"

exports.formatTest =
  "header only test": (test) ->
    test.expect 1

    parsed = [
      {chalk:"overview",name:"hello"}
      {chalk:"function",type:["function"],name:"wah"}
    ]

    formatted = chalkboard.format parsed, header: true
    expected  = '\nhello\n===\n\nwah\n---\n\nType: `function`  \n\n'
    test.equal formatted, expected, "Should only format the first section"

    test.done()

  "rendering private functions/variables": (test) ->
    test.expect 2

    parsed = [
      {chalk: "function", name: "Test", access: "private"}
    ]

    formatted = chalkboard.format parsed, private: false
    test.equal formatted, "", "Should not render private function"

    formatted2 = chalkboard.format parsed, private: true
    expected   = "\nTest\n===\n### Access\nprivate\n"
    test.equal formatted2, expected, "Should render private function"

    test.done()

  "depcreated": (test) ->
    test.expect 1

    parsed = [
      {chalk:"overview", name:"hello"}
      {chalk:"function", name: "Test", deprecated: true}
    ]

    formatted = chalkboard.format parsed
    expected  = "\nhello\n===\n\nTest (Deprecated)\n---\n\n"

    test.equal formatted, expected, "Should indicate function as deprecated"
    test.done()

  "header with url": (test) ->
    test.expect 2

    parsed = [
      {chalk:"overview", name:"Hello", url: "http://www.example.com"}
    ]

    parsed2 = [
      {chalk:"overview", name:"Hello"}
    ]

    formatted = chalkboard.format parsed
    expected  = "\n[Hello](http://www.example.com)\n===\n"
    test.equal formatted, expected, "Should included url with the header name"

    formatted2 = chalkboard.format parsed2
    expected2  = "\nHello\n===\n"
    test.equal formatted2, expected2, "Should render header name without url"

    test.done()

  "description": (test) ->
    test.expect 1

    parsed = [
      {chalk:"overview", name:"Test", description:"Just another description"}
    ]

    formatted = chalkboard.format parsed
    expected  = "\nTest\n===\nJust another description  \n"
    test.equal formatted, expected, "Should render description without title"

    test.done()

  "type": (test) ->
    test.expect 2

    parsed = [
      {chalk: "overview", name:"Test", type:["one"]}
    ]

    formatted = chalkboard.format parsed
    expected  = "\nTest\n===\nType: `one`  \n\n"
    test.equal formatted, expected, "Should render one type"

    parsed2 = [
      {chalk: "overview", name:"Test", type:["one", "two"]}
    ]

    formatted2 = chalkboard.format parsed2
    expected2  = "\nTest\n===\nType: `one, two`  \n\n"
    test.equal formatted2, expected2, "Should render both types"

    test.done()

  "version": (test) ->
    test.expect 1

    parsed = [
      {chalk: "overview", name:"Test", version: "1.0.0"}
    ]

    formatted = chalkboard.format parsed
    expected  = "\nTest\n===\nVersion: `1.0.0`  \n\n"
    test.equal formatted, expected, "Should render version"

    test.done()

  "author and email": (test) ->
    test.expect 2

    parsed = [
      {chalk: "overview", name:"Test", author:"Adrian", email: "test@example.com"}
    ]

    formatted = chalkboard.format parsed
    expected  = "\nTest\n===\n## Author\nAdrian (test@example.com)\n"
    test.equal formatted, expected, "Should render author and email"

    parsed2 = [
      {chalk: "overview", name:"Test", author:"Adrian"}
    ]

    formatted2 = chalkboard.format parsed2
    expected2  = "\nTest\n===\n## Author\nAdrian\n"
    test.equal formatted2, expected2, "Should render author"

    test.done()
