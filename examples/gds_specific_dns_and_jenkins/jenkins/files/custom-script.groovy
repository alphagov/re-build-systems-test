import jenkins.model.*

def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()

jenkinsLocationConfiguration.setAdminAddress("Test Email Address <david.pye@digital.cabinet-office.gov.uk>")

jenkinsLocationConfiguration.save()
