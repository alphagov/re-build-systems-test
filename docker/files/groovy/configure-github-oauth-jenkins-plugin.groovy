#!groovy

// imports
import hudson.security.AuthorizationStrategy
import hudson.security.SecurityRealm
import jenkins.model.Jenkins
import org.jenkinsci.plugins.GithubAuthorizationStrategy
import org.jenkinsci.plugins.GithubSecurityRealm

def env = System.getenv()

// check github auth details are not blank
if ((env['GITHUB_CLIENT_ID'] == null) || (env['GITHUB_CLIENT_SECRET'] == null) || (env['GITHUB_ADMIN_USERS'] == null) || (env['GITHUB_ORGANISATIONS'] == null)) {
  println "GITHUB_CLIENT_ID=${env['GITHUB_CLIENT_ID']}"
  println "GITHUB_CLIENT_SECRET=${env['GITHUB_CLIENT_SECRET']}"
  println "GITHUB_ADMIN_USERS=${env['GITHUB_ADMIN_USERS']}"
  println "GITHUB_ORGANISATIONS=${env['GITHUB_ORGANISATIONS']}"
  println "Skipping Github Auth configuration, GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_ADMIN_USERS or GITHUB_ORGANISTIONS environment variables are blank"
} else {
  println "Configuring Github Authentication"
  println "GITHUB_CLIENT_ID=${env['GITHUB_CLIENT_ID']}"
  println "GITHUB_CLIENT_SECRET=${env['GITHUB_CLIENT_SECRET']}"
  println "GITHUB_ADMIN_USERS=${env['GITHUB_ADMIN_USERS']}"
  println "GITHUB_ORGANISATIONS=${env['GITHUB_ORGANISATIONS']}"

  // parameters
  def githubSecurityRealmParameters = [
    clientID:     env['GITHUB_CLIENT_ID'],
    clientSecret: env['GITHUB_CLIENT_SECRET'],
    githubApiUri: 'https://api.github.com',
    githubWebUri: 'https://github.com',
    oauthScopes:  'read:org'
  ]

  def githubAuthorizationStrategyParameters = [
    adminUserNames:                         env['GITHUB_ADMIN_USERS'],   // admin User Names
    allowAnonymousJobStatusPermission:      false,                       // grant ViewStatus permissions for Anonymous Users
    allowAnonymousReadPermission:           false,                       // grant READ permissions for Anonymous Users
    allowCcTrayPermission:                  false,                       // grant READ permissions for /cc.xml
    allowGithubWebHookPermission:           false,                       // grant READ permissions for /github-webhook
    authenticatedUserCreateJobPermission:   false,                       // grant CREATE Job permissions to all Authenticated Users
    authenticatedUserReadPermission:        false,                       // grant READ permissions to all Authenticated Users
    organizationNames:                      env['GITHUB_ORGANISATIONS'], // participant in organizations
    useRepositoryPermissions:               true                         // use Github repository permissions
  ]

  // https://github.com/jenkinsci/github-oauth-plugin/blob/github-oauth-0.28.1/src/main/java/org/jenkinsci/plugins/GithubSecurityRealm.java
  SecurityRealm githubSecurityRealm = new GithubSecurityRealm(
    githubSecurityRealmParameters.githubWebUri,
    githubSecurityRealmParameters.githubApiUri,
    githubSecurityRealmParameters.clientID,
    githubSecurityRealmParameters.clientSecret,
    githubSecurityRealmParameters.oauthScopes
  )

  // https://github.com/jenkinsci/github-oauth-plugin/blob/github-oauth-0.28.1/src/main/java/org/jenkinsci/plugins/GithubAuthorizationStrategy.java
  AuthorizationStrategy githubAuthorizationStrategy = new GithubAuthorizationStrategy(
    githubAuthorizationStrategyParameters.adminUserNames,
    githubAuthorizationStrategyParameters.authenticatedUserReadPermission,
    githubAuthorizationStrategyParameters.useRepositoryPermissions,
    githubAuthorizationStrategyParameters.authenticatedUserCreateJobPermission,
    githubAuthorizationStrategyParameters.organizationNames,
    githubAuthorizationStrategyParameters.allowGithubWebHookPermission,
    githubAuthorizationStrategyParameters.allowCcTrayPermission,
    githubAuthorizationStrategyParameters.allowAnonymousReadPermission,
    githubAuthorizationStrategyParameters.allowAnonymousJobStatusPermission
  )

  // get Jenkins instance
  Jenkins jenkins = Jenkins.getInstance()

  // add configuration to Jenkins
  jenkins.setSecurityRealm(githubSecurityRealm)
  jenkins.setAuthorizationStrategy(githubAuthorizationStrategy)

  // save current Jenkins state to disk
  jenkins.save()
}
