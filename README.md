
[Chalkboard.js](https://github.com/adrianlee44/chalkboard)
===
[![Build Status](https://travis-ci.org/adrianlee44/chalkboard.png?branch=master)](https://travis-ci.org/adrianlee44/chalkboard)  
An npm package that generate better documentation  
  
### Dependencies
- commander  
- wrench  
- marked  
- underscore  

### Example
```  
#  
# @chalk overview  
# @name example  
# @description  
# This is an example description for an example in readme.  
# @param {String} name Just a random name  
# @param {Boolean} work Does this actually work?  
# @returns {String} Just another value  
#  
```  

### TODO
[TODO Wiki](https://github.com/adrianlee44/chalkboard/wiki/TODO)  


Supported Tags
---

[Wiki Page](https://github.com/adrianlee44/chalkboard/wiki/Supported-Tags)  
  

Getting Started
---

The easiest way to use chalkboard will probably be to install it globally.  
To do so, install the module with:  
```  
npm install -g chalkboard  
```  
  

Usage
---

 Usage: chalkboard [options] [FILES...]  
 Options:  
   -h, --help           output usage information  
   -V, --version        output the version number  
   -o, --output [DIR]   Documentation output file  
   -j, --join [FILE]    Combine all documentation into one page  
   -f, --format [TYPE]  Output format. Default to markdown  
   -p, --private        Parse comments for private functions and varibles  
   -h, --header         Only parse the first comment block  
  

parse
---

Run through code and parse out all the comments  
  
Type: `function`  

### Parameters
**code**  
Type: `String`  
Source code to be parsed  
  
**lang**  
Type: `Object`  
Language settings for the file  
  
**options**  
Type: `Object`  
User settings (default {})  
  

### Returns
Type: `Array`  
List of objects with all the comment block  
  


format
---

Format comment sections into readable format  
  
Type: `function`  

### Parameters
**sections**  
Type: `Array`  
List of comment sections  
  
**options**  
Type: `Object`  

### Returns
Type: `String`  
Formatted markdown code  
  


compile
---

Parse code into documentation  
  
Type: `function`  

### Parameters
**code**  
Type: `String`  
Source code  
  
**options**  
Type: `Object`  
User options  
  
**filepath**  
Type: `String`  
Path of the original file  
  

### Returns
Type: `String`  
Formatted documentation  
  


write
---

Write parsed content into the output file  
  
Type: `function`  

### Parameters
**source**  
Type: `String`  
File path of original file  
  
**content**  
Type: `String`  
Content to write to file  
  
**options**  
Type: `Object`  


configure
---

Configurate user options and validate file paths  
  
Type: `function`  

### Parameters
**options**  
Type: `Object`  
User configurations  
  

## Author
Adrian Lee (adrian@adrianlee.me)
## Copyright and license
2013 Adrian Lee

MIT
