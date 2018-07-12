# Documentation for Reliability Engineering

Once the product team completes the provisioning of the DNS, they are going to contact
Reliability Engineering (RE).

At that point, RE will need to do 3 things:

* "Enable" the team DNS

* Create a Github OAuth app

* Provide the app credentials to the product team

## Enable team DNS

Documentation can be found [here](https://github.com/alphagov/re-build-systems-dns)

## Create a Github OAuth app

This allows the product team to setup authentication to the Jenkins via Github OAuth.

An app needs to be created for each environment (and therefore URL) the team created.

Use the following settings to setup your app. Any fields or options that are not mentioned here can be left blank or with their default value.

The [URL] will follow the pattern `https://[environment].[team_name].build.gds-reliability.engineering`.

* GitHub App name:  `re-build-auth-[team name]-[environment]` , e.g. `re-build-auth-app-eidas-dev`. You may have to deviate from this format if it exceeds 34 characters.

* Description:  Build system for [URL]

* Homepage URL:  [URL]

* User authorization callback URL:  [URL]/securityRealm/finishLogin

* Webhook URL: [URL]

* Permissions > Organization members: `Access: Read-only`

## Provide the app credentials to the product team

For each app you created, provide the `id` and `secret` to the product team, so that
they can complete the provisioning of their Jenkins.
