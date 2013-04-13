
[Chalkboard.js](https://github.com/adrianlee44/chalkboard)
===
An npm package that generate better documentation


#### Dependencies
- commander

- wrench

- marked

- underscore


#### TODO
- Implement @default tag

- Implement @deprecated tag

- Implement @version tag

- Implement comment block



Getting Started
---

Install the module with: `npm install Chalkboard`



parse
---

Run through code and parse out all the comments


#### Type
function
#### Parameters
**code**

Type: `String`

Source code to be parsed


#### Returns
Type: `Array`

List of objects with all the comment block



format
---

Format comment sections into readable format


#### Type
function
#### Parameters
**sections**

Type: `Array`

List of comment sections


#### Returns
Type: `String`

Formatted markdown code



read
---

Read the content of the file


#### Type
function
#### Parameters
**file**

Type: `String`

File path


#### Returns
Type: `Boolean`

File has been read successfully



write
---

Write parsed content into the output file


#### Type
function
#### Parameters
**source**

Type: `String`

File path of original file

**content**

Type: `String`

Content to write to file



run
---

Start the process of generating documentation with source code


#### Type
function
#### Parameters
**List**

Type: `Array`

of arguments


## Author
Adrian Lee (adrian@radianstudio.com)
## Copyright and license
2013 Adrian Lee

MIT
