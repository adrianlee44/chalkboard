
[Chalkboard.js](https://github.com/adrianlee44/chalkboard)
===
[![Build Status](http://img.shields.io/travis/adrianlee44/chalkboard.svg?style=flat)](https://travis-ci.org/adrianlee44/chalkboard)  
An npm package that generate better documentation  
  
  
  
### Dependencies
- commander  
- wrench  
- marked  
- lodash  
  

### Example
```coffeescript  
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


Getting Started
---

The easiest way to use chalkboard will probably be to install it globally.  
  
To do so, install the module with:  
```  
npm install -g chalkboard  
```  
  

Supported Tags
---

[Wiki Page](https://github.com/adrianlee44/chalkboard/wiki/Supported-Tags)  
  

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
  
## Author
Adrian Lee (adrian@adrianlee.me)
## Copyright and license
2014 Adrian Lee

MIT
