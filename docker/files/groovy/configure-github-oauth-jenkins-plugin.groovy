// Script taken from example at https://plugins.jenkins.io/github-oauth and modified.
/*
The MIT License

Copyright (c) 2011 Michael O'Cleirigh
Copyright (c) 2013-2014 Sam Kottler
Copyright (c) 2015-2017 Sam Gleske
Copyright (c) 2004-, Kohsuke Kawaguchi, Sun Microsystems, Inc., and a number of other of contributors - https://github.com/jenkinsci/jenkins

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import jenkins.model.Jenkins
import org.jenkinsci.plugins.GithubAuthorizationStrategy
import org.jenkinsci.plugins.GithubSecurityRealm
import hudson.security.SecurityRealm
import hudson.security.AuthorizationStrategy

def env = System.getenv()

//permissions are ordered similar to web UI
// Admin User Names
String adminUserNames = env['GITHUB_ADMIN_USERS']

// Participant in Organisation
String organisationNames = env['GITHUB_ORGANISATIONS']

// Use Github repository permissions
boolean useRepositoryPermissions = true

// Grant READ permissions to all Authenticated Users
boolean authenticatedUserReadPermission = false

// Grant CREATE Job permissions to all Authenticated Users
boolean authenticatedUserCreateJobPermission = false

// Grant READ permissions for /github-webhook
boolean allowGithubWebHookPermission = false

// Grant READ permissions for /cc.xml
boolean allowCcTrayPermission = false

// Grant READ permissions for Anonymous Users
boolean allowAnonymousReadPermission = false

// Grant ViewStatus permissions for Anonymous Users
boolean allowAnonymousJobStatusPermission = false

// Github api details
String clientID = env['GITHUB_CLIENT_ID']
String clientSecret = env['GITHUB_CLIENT_SECRET']
String githubApiUri = "https://api.github.com"
String githubWebUri = "https://github.com"
String oauthScopes = "read:org"

// check github auth details are not blank
if ((clientID == null) || (clientSecret == null) || (adminUserNames == null) || (organisationNames == null)) {
  SecurityRealm github_security_realm = new GithubSecurityRealm(
    githubWebUri,
    githubApiUri,
    clientID,
    clientSecret,
    oauthScopes
  )

  AuthorizationStrategy github_authorisation = new GithubAuthorizationStrategy(adminUserNames,
      authenticatedUserReadPermission,
      useRepositoryPermissions,
      authenticatedUserCreateJobPermission,
      organisationNames,
      allowGithubWebHookPermission,
      allowCcTrayPermission,
      allowAnonymousReadPermission,
      allowAnonymousJobStatusPermission)

  //check for equality, no need to modify the runtime if no settings changed
  if(!github_authorisation.equals(Jenkins.instance.getAuthorizationStrategy())) {
      Jenkins.instance.setAuthorizationStrategy(github_authorisation)
      Jenkins.instance.setSecurityRealm(github_security_realm)
      Jenkins.instance.save()
  }

  println "Github OAuth2 has been set up."
} else {
  // Print to stdout and stderr.
  System.err.println "Github OAuth2 is not being set up because one or more of the GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_ADMIN_USERS or GITHUB_ORGANISATIONS environment variables have not been set."
  println "Github OAuth2 is not being set up because one or more of the GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, GITHUB_ADMIN_USERS or GITHUB_ORGANISATIONS environment variables have not been set."
}
