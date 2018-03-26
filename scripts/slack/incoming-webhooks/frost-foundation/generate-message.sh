#!/bin/bash

#
# Get attachment color based on scope
#
function get_color() {
    local scope=$1

    local color="FF0000"

    case $scope in
        MAJOR)
            color="871455"
            ;;
        MINOR)
            color="32619D"
            ;;
        PATCH)
            color="61BD63"
            ;;
    esac

    echo "$color"
}

#
# Generate the desired message to send to the Slack "frost-foundation" incoming webhook integration
#
function generate_message() {
    local scope=$1
    local current_version=$2
    local previous_version=$3
    local organization_name=$4
    local package=$5
    local changelog=$6

    local color
    local message
    local title="$scope / $current_version / $package"

    color=$(get_color "$scope")

    # @TODO
    # Do not know why the string of "send-message.sh frost-foundation" is being prepended to content but this removes it
    changelog="$(echo "$changelog" | sed 's/send-message.sh frost-foundation//g')"

    # Replace instances of ** to * convert from GitHub to Slack styling
    changelog="$(echo "$changelog" | sed 's/\*\*/\*/g')"

    # Replace instances of "
    changelog="$(echo "$changelog" | sed 's/"//g')"

    message="{
        \"username\": \"frost-foundation\",
        \"attachments\": [
            {
                \"fallback\": \"$title\",
                \"color\": \"$color\",
                \"fields\": [
                    {
                        \"title\": \"$title\",
                        \"value\": \"<$(get_compare_versions_url "$organization_name" "$package_name" "$previous_version" "$current_version")|Compare to previous version>\n$changelog\",
                        \"short\": false
                    }
                ]
            }
        ]
    }"

    echo "$message"
}

#
# Generate error message about missing "respository" property in package.json file
#
function generate_repository_error_message() {
    local package_name=$1
    local color
    local title="ERROR: Cannot post release information for $package_name"

    color=$(get_color)

    local message="{
        \"username\": \"frost-foundation\",
        \"attachments\": [
            {
                \"fallback\": \"$title\",
                \"color\": \"$color\",
                \"fields\": [
                    {
                        \"title\": \"$title\",
                        \"value\": \"There is not a _*repository*_ property set in the _package.json_ file for *$package_name* so no release information is able to be posted to this channel.\",
                        \"short\": false
                    }
                ]
            }
        ]
    }"

    echo "$message"
}
