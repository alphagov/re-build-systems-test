import jenkins.model.*

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

jenkinsLocationConfiguration.setAdminAddress("Test Email Address <myemail@domain>")

jenkinsLocationConfiguration.save()
