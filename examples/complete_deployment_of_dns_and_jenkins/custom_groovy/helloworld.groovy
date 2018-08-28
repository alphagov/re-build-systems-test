import java.io.File
def Example(myfile, mymessage){
      new File(myfile).withWriter('utf-8') {
         writer -> writer.writeLine mymessage
      }
}

Example('/var/jenkins_home/example.txt', 'Hello World')
println "helloworld custom groovy script"
