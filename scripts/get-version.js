#!/usr/bin/env node

'use strict'

const util = require('util')
const exec = util.promisify(require('child_process').exec)

const whichPackage = process.argv[2]
const packageVersion = process.argv[3]
const whichVersion = process.argv[4]

/**
 * Get either the current or previous version of an NPM package
 *
 * @param {String} whichPackage NPM package to interrogate
 * @param {String} packageVersion "version" property value from package.json file
 * @param {?String} whichVersion If 'previous' then previous version, otherwise current
 *
 * @returns {String|undefined} Current or previous version of the NPM package
 */
async function getVersion(whichPackage, packageVersion, whichVersion) {
    const {stdout, stderr} = await exec(`npm show ${whichPackage} versions --json`)

    if (!stderr) {
        const versions = JSON.parse(stdout)
        const publishedNpmVersion = versions[versions.length-1]

        let latest
        let previous

        // NPM registry has latest package version
        if (publishedNpmVersion == packageVersion) {
            latest = publishedNpmVersion
            previous = versions[versions.length-2]

        // NPM registry does not have latest package version
        } else {
            latest = packageVersion
            previous = versions[versions.length-1]
        }

        console.log(whichVersion === 'previous' ? previous : latest)
    }
}

getVersion(whichPackage, packageVersion, whichVersion)
