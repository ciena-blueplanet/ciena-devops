#!/bin/bash

#
# REQUIRED ENVIRONMENT VARIABLES IN CI ENVIRONMENT
#
# SLACK_INCOMING_WEBHOOK_URL - url of the Slack Incoming Webhook
# TRAVIS_PULL_REQUEST - set by TravisCI (not needed if not in TravisCI environment)
# TEAMCITY_PULL_REQUEST - set by TeamCity (not needed if not in TeamCity environment)
#

#
# Include other scripts
#
source $(dirname $0)/../../package-info.sh
source $(dirname $0)/ui-platform/generate-message.sh

#
# Send message to the Slack "ui-platform" incoming webhook integration
#
function send_message() {
    curl -X POST --data-urlencode "payload=$1" "$SLACK_INCOMING_WEBHOOK_URL"
}

# Run only for builds that aren’t coming from pull requests
if [ "${TRAVIS_PULL_REQUEST}" = "false" ] || [ "${TEAMCITY_PULL_REQUEST}" = "false" ];
then
    organization_name=$(get_organization_name)
    package_name=$(get_package_name)

    if [ "$organization_name" = "undefined" ];
    then
        message=$(generate_repository_error_message "$package_name")
    else
        current_version=$(get_current_version "$package_name")
        previous_version=$(get_previous_version "$package_name")
        release_type=$(get_release_type "$previous_version" "$current_version")
        changelog=$(get_changelog "$organization_name" "$package_name")

        message=$(generate_message "$release_type" "$current_version" "$previous_version" "$organization_name" "$package_name" "$changelog")
    fi

    send_message "$message"
fi
