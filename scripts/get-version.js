#!/usr/bin/env node

'use strict'

const util = require('util')
const exec = util.promisify(require('child_process').exec)

const whichPackage = process.argv[2]
const whichVersion = process.argv[3]

/**
 * Get either the current or previous version of an NPM package
 *
 * @param {String} whichPackage NPM package to interrogate
 * @param {?String} whichVersion If 'previous' then previous version, otherwise current
 *
 * @returns {String|undefined} Current or previous version of the NPM package
 */
async function getVersion(whichPackage, whichVersion) {
    const {stdout, stderr} = await exec(`npm show ${whichPackage} versions --json`)

    if (!stderr) {
        const offset = (whichVersion === 'previous') ? 1 : 0
        const versions = JSON.parse(stdout)

        console.log(versions[versions.length - 1 - offset])
    }
}

getVersion(whichPackage, whichVersion)
