import jenkins.model.*

def instance = Jenkins.getInstance()

instance.setSlaveAgentPort(50000)

instance.save()
