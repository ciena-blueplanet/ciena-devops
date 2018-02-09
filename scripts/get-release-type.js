#!/usr/bin/env node

'use strict'

const semver = require('semver')

const scope = semver.diff(process.argv[2], process.argv[3])

console.log(scope.toUpperCase())
