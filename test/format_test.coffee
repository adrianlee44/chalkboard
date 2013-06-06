chalkboard = require "../chalkboard.js"

exports.formatTest =
  "header only test": (test) ->
    test.expect 1

    parsed = [
      {chalk:"overview",name:"hello"}
      {chalk:"function",type:"function",name:"wah"}
    ]

    formatted = chalkboard.format parsed, header: true
    expected = '\nhello\n===\n\nwah\n---\n\nType: `function`  \n\n'
    test.equal formatted, expected, "Should only format the first section"

    test.done()