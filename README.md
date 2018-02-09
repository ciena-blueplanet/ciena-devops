# ciena-devops
A collection of scripts and configurations used by the Ciena organization in their DevOps

## scripts/slack/incoming-webhooks/send-message.sh

After `pr-bumper` has merged an outstanding PR and bumped the package version this script should then be ran to send a
message to the `#ui-platform` Slack channel.

The message will look like:

![Example Slack Message](https://user-images.githubusercontent.com/435544/35946094-19944f76-0c28-11e8-8c6d-783241c4eff4.png)

PATCHES will have a green color, MINOR blue, and MAJOR burgundy.

An error message may also be sent when an error is encountered:

![Example Slack Error Message](https://user-images.githubusercontent.com/435544/35946206-80c3bee8-0c28-11e8-81c1-b351050ddedb.png)


### package.json Configuration

A `repository` property needs to added to the _package.json_ file, such as:

```json
"repository": {
  "type": "git",
  "url": "https://<url>/<organization>/<repo>.git"
},
```


### TravisCI Configuration

An environment variable needs to be added to the TravisCI configuration at [https://travis-ci.org](https://travis-ci.org) as well as two additions need to be added to the _.travis.yml_ file.

The environment variable that needs to be added to the respective package's configuration in TravisCI is
`SLACK_INCOMING_WEBHOOK_URL` and needs to be set to the url of the incoming webhook integration for the `#ui-platform`
channel.  To do this visit `https://travis-ci.org/<organization>/<repo>/settings`. **NOTE:** When adding the
`SLACK_INCOMING_WEBHOOK_URL` variable, make sure to keep the "_Display value in build log_" set to "_OFF_" otherwise the url will be written to the build logs for the public to see.

The additions to the _.travis.yml_ file are to add the `ciena-devops` package to the `npm install` in the
`before_install` configuration, such as:

```yaml
before_install:
- npm install -g pr-bumper@^3.2.3 ciena-devops^1.0.0
```

The second addition is to add an `after_deploy` configuration, such as:

```yaml
after_deploy:
- $(npm root -g)/ciena-devops/scripts/slack/incoming-webhooks/send-message.sh
```

### TeamCity Configuration

@TODO


## scripts/package-info.sh

This script contains several functions related to retrieving information about packages.


## Creating new scripts

When developing new scripts you must change the permissions of them before committing, as per
[https://docs.travis-ci.com/user/customizing-the-build/#Implementing-Complex-Build-Steps](https://docs.travis-ci.com/user/customizing-the-build/#Implementing-Complex-Build-Steps)

You may also find the [https://www.shellcheck.net](https://www.shellcheck.net) tool helpful when writing `bash` 
scripts.
