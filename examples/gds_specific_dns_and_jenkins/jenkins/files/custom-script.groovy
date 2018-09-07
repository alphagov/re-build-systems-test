import jenkins.model.*
import java.util.logging.Logger
import hudson.plugins.git.*;

// Custom Jenkins configuration
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
jenkinsLocationConfiguration.setAdminAddress("Test Email Address <myemail@domain>")
jenkinsLocationConfiguration.save()

// Custom Jenkins plugins
def pluginParameter="greenballs"

def logger = Logger.getLogger("")
def installed = false
def initialized = false
def plugins = pluginParameter.split()
logger.info("" + plugins)
def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()
plugins.each {
  logger.info("Checking " + it)
  if (!pm.getPlugin(it)) {
    logger.info("Looking UpdateCenter for " + it)
    if (!initialized) {
      uc.updateAllSites()
      initialized = true
    }
    def plugin = uc.getPlugin(it)
    if (plugin) {
      logger.info("Installing " + it)
        def installFuture = plugin.deploy()
      while(!installFuture.isDone()) {
        logger.info("Waiting for plugin install: " + it)
        sleep(3000)
      }
      installed = true
    }
  }
}

// Definition of jobs
def parent = Jenkins.instance
def jobDefinitions =
[
   [
      "name" : "build-sample-java-app-from-custom-configuration",
      "scm" : "https://github.com/alphagov/re-build-systems-sample-java-app",
      "description" : "some describing",
      "jenkinsFilePath" : "Jenkinsfile",
   ],
   [
      "name" : "build-sample-java-app-from-custom-configuration-again",
      "scm" : "https://github.com/alphagov/re-build-systems-sample-java-app",
      "description" : "some more describing",
      "jenkinsFilePath" : "Jenkinsfile",
   ]
]

jobDefinitions.each{jobEntry->
  def scm = new GitSCM(jobEntry["scm"])
  def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, jobEntry["jenkinsFilePath"])
  def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, jobEntry["name"])
  job.description = jobEntry["description"]
  job.definition = flowDefinition
}

if (installed) {
  logger.info("Plugins installed, initializing a restart!")
  instance.save()
  instance.restart()
}
