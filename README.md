# ciena-devops
A collection of scripts and configurations used by the Ciena organization in their DevOps

## scripts/slack/incoming-webhooks/send-message.sh

After `pr-bumper` has merged an outstanding PR and bumped the package version this script should then be ran to send a
message to the `#frost-foundation` Slack channel.

The message will look like:

![Example Slack Message](https://user-images.githubusercontent.com/435544/35946094-19944f76-0c28-11e8-8c6d-783241c4eff4.png)

PATCHES will have a green color, MINOR blue, and MAJOR burgundy.

An error message may also be sent when an error is encountered:

![Example Slack Error Message](https://user-images.githubusercontent.com/435544/35946206-80c3bee8-0c28-11e8-81c1-b351050ddedb.png)

## Configuration

### package.json

A `repository` property needs to added to the _package.json_ file, such as:

```json
"repository": {
  "type": "git",
  "url": "https://<url>/<organization>/<repo>.git"
},
```


### TravisCI

An environment variable needs to be added to the TravisCI configuration at [https://travis-ci.org](https://travis-ci.org) as well as two additions need to be added to the _.travis.yml_ file.

The environment variable that needs to be added to the respective package's configuration in TravisCI is
`SLACK_INCOMING_WEBHOOK_URL` and needs to be set to the url of the incoming webhook integration for the
`#frost-foundation` channel.  To do this visit `https://travis-ci.org/<organization>/<repo>/settings`. **NOTE:** When adding the `SLACK_INCOMING_WEBHOOK_URL` variable, make sure to keep the "_Display value in build log_" set to "_OFF_"
otherwise the url will be written to the build logs for the public to see.

The additions to the _.travis.yml_ file are to add the `ciena-devops` package to the `npm install` in the
`before_install` configuration, such as:

```yaml
before_install:
- npm install -g pr-bumper@^3.7.0 ciena-devops^1.1.0
```

The second addition is to add an `after_deploy` configuration, such as:

```yaml
after_deploy:
- $(npm root -g)/ciena-devops/scripts/slack/incoming-webhooks/send-message.sh
```

### TeamCity

#### #1

An environment variable needs to be added to the TeamCity project configuration named `env.tc.slack.frost-foundation.incoming.webhook` whose value is set to the url of the incoming webhook integration for the `#frost-foundation` channel.

#### #2

The `Setup CI Environment (inherited)` build step needs to be duplicated and modified, with the original build step being set to disabled.  Name the new build step: `Setup CI Environment (deviates from inherited by exporting SLACK_INCOMING_WEBHOOK_URL`

The modification that needs to be made is to add

```bash
# Fill in SLACK_INCOMING_WEBHOOK_URL
export SLACK_INCOMING_WEBHOOK_URL="%env.tc.slack.frost-foundation.incoming.webhook%"
```

somewhere within the `cat << EOF > ${ENV_DIR}/nenv` section, before the `EOF` entry.


#### #3

A new build step needs to be added to the TeamCity project configuration with the following information:

![TeamCity Build Step](https://user-images.githubusercontent.com/435544/37919429-6ed747d2-30e9-11e8-878f-6c698fb64dda.png)

where the contents of the `Custom script` are:

```bash
#!/bin/bash
NAME=frost-ci-image
IMAGE=$(docker images | grep ${NAME} | awk '{print$3}')
CONTAINER=$(docker ps -a | grep $IMAGE | awk '{print$1}')

# Fill in TEAMCITY_PULL_REQUEST
stripped_branch=$(echo "%teamcity.build.branch%" | sed -e "s/\/merge//")
re='^[0-9]+$'
if [[ $stripped_branch =~ $re ]]
then
    export TEAMCITY_PULL_REQUEST="$stripped_branch"
else
    export TEAMCITY_PULL_REQUEST="false"
fi

if [[ "$TEAMCITY_PULL_REQUEST" = "false" ]]
then
    docker exec $CONTAINER nenv npm install -g ciena-devops@^1.1.0 || exit $?
    docker exec $CONTAINER nenv /opt/node-envs/%env.node_version%/lib/node_modules/ciena-devops/scripts/slack/incoming-webhooks/send-message.sh || exit $?
fi
```

and set to run after the `Slack Notification (1) (inherited)` step and before the `Cleanup Container (inherited)` step.



## scripts/package-info.sh

This script contains several functions related to retrieving information about packages.


## Creating new scripts

When developing new scripts you must change the permissions of them before committing, as per
[https://docs.travis-ci.com/user/customizing-the-build/#Implementing-Complex-Build-Steps](https://docs.travis-ci.com/user/customizing-the-build/#Implementing-Complex-Build-Steps)

You may also find the [https://www.shellcheck.net](https://www.shellcheck.net) tool helpful when writing `bash` 
scripts.

