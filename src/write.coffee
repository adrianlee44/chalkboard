#
# @chalk function
# @function
# @name write
# @description
# Write parsed content into the output file
# @param {String} source  File path of original file
# @param {String} content Content to write to file
# @param {Object} options
#

_      = require "lodash"
cwd    = process.cwd()
fs     = require "fs"
path   = require "path"
wrench = require "wrench"

module.exports = (source, content, options = {}) ->
  # Check if all the generated documentations are written to one file
  if options.join?
    output = path.join cwd, options.join
    fs.appendFileSync output, content
    return output

  # Check if output folder is specify
  else if options.output?
    base     = _.find options.files, (file) -> source.indexOf file is 0
    filename = path.basename source, path.extname(source)
    relative = path.relative base, path.dirname(source)
    filePath = path.join(relative, filename) + ".md"
    output   = path.join cwd, options.output, filePath
    dir      = path.dirname output

    unless fs.existsSync dir
      wrench.mkdirSyncRecursive dir, 0o777

    fs.writeFileSync output, content
    return output

  else
    console.log content
