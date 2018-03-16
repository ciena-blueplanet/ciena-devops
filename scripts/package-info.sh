#!/bin/bash

#
# Get the GitHub url to compare the diff between two package versions
#
function get_compare_versions_url() {
    local organization_name=$1
    local package_name=$2
    local previous_version=$3
    local current_version=$4
    local host

    host=$(get_github_host "$organization_name")

    echo "https://$host/$organization_name/$package_name/compare/v$previous_version...v$current_version"
}

#
# Get CHANGELOG entry for current version
#
function get_changelog() {
    local organization_name=$1
    local package_name=$2

    local changelog
    local previous_version

    previous_version=$(get_previous_version "$package_name")

    # Escaping for use later on in pattern matching
    previous_version=$(echo $previous_version | sed 's/\./\\./g')

    ## Retrieve CHANGELOG.md file for package

    # Create temporary file to store content into
    changelog_file="$(mktemp)"

    # Delete the temporary file at script end
    trap 'rm -rf $changelog_file' EXIT

    # Store CHANGELOG file content into temp file.
    # Was easier reading file from disk rather than piping in wget call
    wget -O- -q "$(get_changelog_url "$organization_name" "$package_name")" > "$changelog_file"

    ## Extract version-specific entries
    while read -r line;
    do
        # If the line begins with "# 1.0.4" (without quotes), for example, then have reached entries for previous version
        if [[ "$line" =~ ^#[[:space:]]{1}$previous_version.*$ ]];
        then
            break
        else
            # Skip the line beginning with "# 2.0.0" (without quotes), for example
            [[ "$line" =~ ^#[[:space:]]{1}.*$ ]] && continue
            changelog+="$line\n"
        fi
    done < "$changelog_file"

    ## Return entries
    echo "$changelog"
}

#
# Get the url of the packages CHANGELOG file
#
function get_changelog_url() {
    local organization_name=$1
    local package_name=$2
    local host

    host=$(get_github_raw_host "$organization_name")

    echo "https://$host/$organization_name/$package_name/master/CHANGELOG.md"
}

#
# Get current package version
#
function get_current_version() {
    version=$(get_package_version)

    get-version "$1" "$version"
}

#
# Get GitHub host
#
function get_github_host() {
    local organization_name=$1
    local host

    if [ "$organization_name" = "ciena-blueplanet" ] || [ "$organization_name" = "ciena-frost" ];
    then
        host="github.com"
    else
        host="github.cyanoptics.com"
    fi

    echo "$host"
}

#
# Get GitHub host for raw format of content
#
function get_github_raw_host() {
    local organization_name=$1
    local host

    if [ "$organization_name" = "ciena-blueplanet" ] || [ "$organization_name" = "ciena-frost" ];
    then
        host="raw.githubusercontent.com"
    else
        host="github.cyanoptics.com/raw"
    fi

    echo "$host"
}

#
# Get "organization" property from package.json file
#
function get_organization_name () {
    local extracted_name
    local organization_name
    local package_name

    # Supports both structures of '"repository": "url"' and '"repository": {"type": "git", "url": "url"}'
    organization_name="$(node -e "let repository = require('./package.json').repository; repository = (repository && repository.url) ? repository.url : repository; console.log(repository);")"
    package_name=$(get_package_name)

    if [ "$organization_name" != "undefined" ];
    then
        # format: git@github.com:ciena-blueplanet/ciena-devops.git
        extracted_name=$(echo "$organization_name" | grep -Eo "[[:alpha:]-]*\/$package_name.git")

        if [ "$extracted_name" = "" ];
        then
            # format: http://github.com/ciena-blueplanet/ciena-devops.git
            extracted_name=$(echo "$organization_name" | grep -Eo "[[:alpha:]]*\/$package_name.git")
        fi

        # format: ciena-blueplanet/ciena-devops.git
        organization_name=$(echo "$extracted_name" | sed "s/\/$package_name.git//g")
    fi

    echo "$(echo "$organization_name" | tr '[:upper:]' '[:lower:]')"
}

#
# Get "name" property from package.json file
#
function get_package_name () {
    echo "$(node -e "console.log(require('./package.json').name)" | tr '[:upper:]' '[:lower:]')"
}

#
# Get "version" property from package.json file
#
function get_package_version () {
    echo "$(node -e "console.log(require('./package.json').version)")"
}

#
# Get previous package version
#
function get_previous_version() {
    version=$(get_package_version)

    get-version "$1" "$version" previous
}

#
# Get difference between two versions by the release type
#
function get_release_type() {
    local previous_version=$1
    local new_version=$2

    get-release-type "$previous_version" "$current_version"
}
