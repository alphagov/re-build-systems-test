import jenkins.model.*

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

jenkinsLocationConfiguration.setAdminAddress("Test Email Address test.email@some.random.domain>")

jenkinsLocationConfiguration.save()
