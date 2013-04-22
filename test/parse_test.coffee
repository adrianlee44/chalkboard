chalkboard = require "../chalkboard.js"

exports.parseTest =
  setUp: (callback) ->
    @lang =
      name:         'coffeescript'
      symbol:       '#'
      block:        '###'
      commentRegex: /^\s*#{1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      blockRegex:   /###/

    callback()

  "chalk test": (test) ->
    test.expect 2

    code = """
      #
      # @name hello
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret.length, 0, "No section should be parsed"

    code2 = """
      #
      # @chalk overview
      # @name hello
      #
    """
    ret = chalkboard.parse code2, @lang, {}
    test.equal ret.length, 1, "1 section should be parsed"

    test.done()

  "multiple chalk test": (test) ->
    code = """
      #
      # @chalk overview
      # @name hello
      #

      #
      # @chalk function
      # @function
      # @name wah
      #
    """

    ret = chalkboard.parse code, @lang, {}
    test.equal ret.length, 2, "2 sections should be parsed"
    test.done()

  "name test": (test) ->
    code = """
      #
      # @chalk overview
      # @name hello
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].name, "hello"
    test.done()

  "description test": (test) ->
    code = """
      #
      # @chalk overview
      # @description
      # This is a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].description, "This is a test  \n"
    test.done()

  "multi-line description test": (test) ->
    code = """
      #
      # @chalk overview
      # @description
      # This is a test
      # Second line of the description
      # - Point 1
      # - Point 2
      #
    """
    output  = "This is a test  \n"
    output += "Second line of the description  \n"
    output += "- Point 1  \n"
    output += "- Point 2  \n"

    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].description, output
    test.done()

  "param test": (test) ->
    test.expect 4

    code = """
      #
      # @chalk overview
      # @param {String} test Another test name
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].param.length, 1

    param = ret[0].param[0]

    test.equal param.name,        "test"
    test.equal param.type,        "String"
    test.equal param.description, "Another test name  \n"

    test.done()

  "multiple param test": (test) ->
    code = """
      #
      # @chalk overview
      # @param {String} test Another test name
      # @param {Integer} random Just another random integer
      #
    """
    ret = chalkboard.parse code, @lang, {}

    test.equal ret[0].param.length, 2

    test.done()