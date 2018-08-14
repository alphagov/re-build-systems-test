import jenkins.model.JenkinsLocationConfiguration
jlc = JenkinsLocationConfiguration.get()
jlc.setUrl(env['JENKINS_URL']) 
println(jlc.getUrl())
jlc.save()
