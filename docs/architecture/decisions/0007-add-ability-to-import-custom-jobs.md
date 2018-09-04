# 7. Provide ability for the user to import custom jobs

Date: 2018-08-24

## Status

Accepted

## Context

We need the user to be able to define Jenkins jobs in code and be able to import them into Jenkins.

We have identified a number of ways to do this:

1) define jobs with Groovy and inject the script, as we do for the Jenkins configuration
2) scan a Github account, looking for repositories matching a pattern - that would automatically create the jobs
3) [Jenkins Job Builder]
4) [Job DSL plugin]

Option 1) is the easiest for us as we don't need to implement anything new, as we can use the mechanism of injecting Groovy script which is already implemented. It is also relatively easy to use for the user. There is the limitation that the code for the jobs and configuration can't exceed 16 KB but we believe that is enough for compact Jenkins installations (a Jenkins with hundreds of jobs is an anti-pattern). [The limit] is because we use [user data] for that purpose.

Option 2) feels quite easy for the user, however the implementation could have been quite complex. Moreover, that would have made the installation of our Jenkins more complex, as the user would need to pass extra parameter to the Jenkins Terraform module: at least one regular expression to filter the repositories to match, and a Github personal token. The token is needed because scanning Github as n authenticated user is extremely slow, while if authenticated it should take only a few minutes. As the module needs a token as an input, there is the extra complexity to manage that secret.

For a quick survey it seems option 3) (Jenkins Job Builder) is the most commonly used at GDS (e.g. Notify, Digital Marketplace) - people likes it reasonably but some issues were pointed out (e.g. difficulty in upgrading to a newer version or in escaping quotes correctly).
[GOV.UK] and Pay use a more ad-hoc homebrewed approach.
Anyway, both groups rely on Puppet/Chef to inject their jobs into Jenkins.
We allow users to install their configuration management tool via cloud-init, so the user is still free to override any mechanism we provide.

Option 4) hasn't been explored much, as we felt we already found a good solution. However, if we revisit the decision made in this PR, this tool should be evaluated.

## Decision

We decided to implement solution 1) to keep things simple and because of time constraints. However, in the future, we may consider to change to another solution if we feel there is the user need.

## Consequences

The user is able to import jobs into Jenkins that are defined in code. The constraint is that the definition of the jobs and configuration can't exceed 16 KB.

[JenkinsJobBuilder]: https://docs.openstack.org/infra/jenkins-job-builder/#jenkins-job-builder
[Job DSL plugin]: https://github.com/jenkinsci/job-dsl-plugin
[GOV.UK]: https://docs.publishing.service.gov.uk/manual/testing-projects.html
[user data]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
[The limit]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
