#!/usr/bin/env node

/*
 * Chalkboard
 * https://github.com/adrianlee44/chalkboard
 *
 * Copyright (c) 2013 Adrian Lee
 * Licensed under the MIT license.
 */

var path = require('path');
var fs = require('fs');
var dir = path.join(path.dirname(fs.realpathSync(__filename)), '../');
require(dir + 'chalkboard.js').run(process.argv);