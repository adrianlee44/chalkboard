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