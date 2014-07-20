#
# @chalk function
# @function
# @name format
# @description
# Format comment sections into readable format
# @param   {Array}  sections List of comment sections
# @param   {Object} options
# @returns {String} Formatted markdown code
#

_    = require "lodash"
util = require "./lib/util"


module.exports = (sections, options = {}) ->
  output = ""
  footer = ""
  for section, index in sections
    omitList = ["chalk"]

    # Skip through the rest of the sections
    break if options.header and index > 1

    # Skip through formatting private functions/variables
    continue if section.access? and (section.access is "private" and not options.private)

    if section.name?
      output += "\n"
      if index
        output += "#{section.name}"
        output += " (Deprecated)" if section.deprecated? and section.deprecated
        output += "\n---\n"
        omitList.push "deprecated"

      else
        if section.url?
          output += "[#{section.name}](#{section.url})" if section.url?
          omitList.push "url"
        else
          output += "#{section.name}"

        output +="\n==="

      output += "\n"
      omitList.push "name"

    if section.description?
      output += "#{section.description}  \n"
      omitList.push "description"

    if section.type?
      output += "Type: `#{section.type.join(", ")}`  \n\n"
      omitList.push "type"

    if section.version?
      output += "Version: `#{section.version}`  \n\n"
      omitList.push "version"

    if section.author? and not index
      footer += util.formatKeyValue "author", section.author, false, 2

      if section.email?
        footer += " (#{section.email})"
      footer += "\n"

    copyrightAndLicense =
      header:  []
      content: []

    if section.copyright? and not index
      copyrightAndLicense.header.push "copyright"
      copyrightAndLicense.content.push section.copyright

    if section.license? and not index
      copyrightAndLicense.header.push "license"
      copyrightAndLicense.content.push section.license

    if section.copyright? or section.license?
      footer += util.formatKeyValue copyrightAndLicense.header.join(" and "),
        copyrightAndLicense.content.join("\n\n"), true, 2

    # Copyright, license, email and author should only be parsed once
    omitList.push "copyright", "license", "author", "email"

    for key, value of _.omit section, omitList
      output += util.formatKeyValue(key, value)

  output += footer

  return output
