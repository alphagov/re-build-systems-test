import jenkins.model.*
import hudson.plugins.git.*;

// Custom Jenkins configuration

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

jenkinsLocationConfiguration.setAdminAddress("Test Email Address <myemail@domain>")

jenkinsLocationConfiguration.save()

// Definition of jobs

def parent = Jenkins.instance

// Job build-sample-java-app-from-custom-configuration
def scm = new GitSCM("https://github.com/alphagov/re-build-systems-sample-java-app")
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "build-sample-java-app-from-custom-configuration")
job.description = "Build and test sample app at https://github.com/alphagov/re-build-systems-sample-java-app"
job.definition = flowDefinition

parent.reload()
