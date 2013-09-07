chalkboard = require "../chalkboard.js"

exports.parseTest =
  setUp: (callback) ->
    @lang =
      name:         'coffeescript'
      symbol:       '#'
      block:        '###'
      commentRegex: /^\s*(?:#){1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      lineRegex:    /^\s*(?:#){1,2}\s+(.*)/
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

  "param multiple line description test": (test) ->
    code = """
      #
      # @chalk overview
      # @param {String} test Another test name
      # This is the second line
      # And then there is the third line
      #
    """
    ret    = chalkboard.parse code, @lang, {}
    param  = ret[0].param[0]
    output = "Another test name  \nThis is the second line  \nAnd then there is the third line  \n"

    test.equal param.description, output

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

  "multiple multi-line params description test": (test) ->
    code = """
      #
      # @chalk overview
      # @param {String} test Another test name
      # Line 2 of the first param
      # @param {Integer} random Just another random integer
      # With just another random character
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].param.length, 2

    params = ret[0].param
    test.equal params[0].description, "Another test name  \nLine 2 of the first param  \n"
    test.equal params[1].description, "Just another random integer  \nWith just another random character  \n"

    test.done()

  "comment block": (test) ->
    code = """
      ###
      @chalk overview
      @name Testing
      @description
      Hello World
      ###
    """
    test.expect 2

    ret = chalkboard.parse code, @lang, {}

    test.equal ret[0].name, "Testing"
    test.equal ret[0].description, "Hello World  \n"

    test.done()

  "email test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @email test@test.com
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].email, "test@test.com"
    test.done()

  "copyright test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @copyright Test User c 2000
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].copyright, "Test User c 2000"
    test.done()

  "license test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @license MIT
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].license, "MIT"
    test.done()

  "url test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @url http://www.example.com
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].url, "http://www.example.com"
    test.done()

  "variable type identifier test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @variable
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].type, "variable"
    test.done()

  "function type identifier test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @function
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].type, "function"
    test.done()

  "private access identifier test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @private
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].access, "private"
    test.done()

  "public access identifier test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @public
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].access, "public"
    test.done()

  "using @access": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @access public
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].access, "public"
    test.done()

  "since tag test": (test) ->
    code = """
      # @chalk overview
      # @since Yesterday
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].since, "Yesterday"
    test.done()

  "version test": (test) ->
    code = """
      #
      # @chalk overview
      # @name Testing Module
      # @version 9000+
      # @description
      # This is just a test
      #
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret[0].version, "9000+"
    test.done()

exports.jsParseTest =
  setUp: (callback) ->
    @lang =
      name:         'javascript'
      symbol:       '//'
      start:        '/*'
      end:          '*/'
      commentRegex: /^\s*(?:\/\/){1,2}\s*(?:@(\w+))?(?:\s*(.*))?/
      lineRegex:    /^\s*(?:\/\/){1,2}\s+(.*)/
      startRegex:   /\/\*/
      endRegex:     /\*\//

    callback()

  "js chalk test": (test) ->
    test.expect 2

    code = """
      //
      // @name hello
      //
    """
    ret = chalkboard.parse code, @lang, {}
    test.equal ret.length, 0, "No section should be parsed"

    code2 = """
      //
      // @chalk overview
      // @name hello
      //
    """
    ret = chalkboard.parse code2, @lang, {}
    test.equal ret.length, 1, "1 section should be parsed"

    test.done()

  "js comment block": (test) ->
    code = """
      /*
      @chalk overview
      @name Testing
      @description
      Hello World
      */
    """
    test.expect 2

    ret = chalkboard.parse code, @lang, {}

    test.equal ret[0].name, "Testing"
    test.equal ret[0].description, "Hello World  \n"

    test.done()