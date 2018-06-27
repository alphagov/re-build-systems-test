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

An app needs to be created for each environment (and therefore URL) the team created. Use these settings (placeholders you need to replace are in square brackets):

* Application name:  re-build-auth-app-[team name]-[environment] , e.g. `re-build-auth-app-eidas-dev`

* Homepage URL:  [URL]

* Application description:  Build system for [URL]

* Authorization callback URL:  [URL]/securityRealm/finishLogin

## Provide the app credentials to the product team

For each app you created, provide the `id` and `secret` to the product team, so that
they can complete the provisioning of their Jenkins.