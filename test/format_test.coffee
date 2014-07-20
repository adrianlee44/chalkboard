require "coffee-script/register"

chalkboard = require "../src/chalkboard"

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

  "copyright and license": (test) ->
    test.expect 3

    parsed = [
      {chalk: "overview", name:"Test", copyright:"Somone 2013"}
    ]
    formatted = chalkboard.format parsed
    expected  = "\nTest\n===\n## Copyright\nSomone 2013\n"
    test.equal formatted, expected, "Should render copyright"

    parsed2 = [
      {chalk: "overview", name:"Test", license:"MIT"}
    ]
    formatted2 = chalkboard.format parsed2
    expected2  = "\nTest\n===\n## License\nMIT\n"
    test.equal formatted2, expected2, "Should render license"

    parsed3 = [
      {chalk: "overview", name:"Test", license:"MIT", copyright:"Someone 2013"}
    ]
    formatted3 = chalkboard.format parsed3
    expected3  = "\nTest\n===\n## Copyright and license\nSomeone 2013\n\nMIT\n"
    test.equal formatted3, expected3, "Should render license and copyright"

    test.done()

  "other tags": (test) ->
    tags = [
      {tag: "default", value: "123", upper: "Default"}
      {tag: "since", value: "yesterday", upper: "Since"}
      {tag: "param", value: "123", upper: "Parameters"}
      {tag: "TODO", value: "something", upper: "TODO"}
      {tag: "example", value: "chalkboard hello", upper: "Example"}
    ]
    test.expect tags.length
    nameOut = "\nTest\n===\n"
    for tag in tags
      parsed = [{chalk:"overview", name:"Test"}]
      parsed[0][tag.tag] = tag.value

      formatted = chalkboard.format parsed
      expected  = "#{nameOut}### #{tag.upper}\n#{tag.value}\n"
      test.equal formatted, expected, "Render @#{tag.tag} correctly"

    test.done()
