# Documentation for the product team

## Provisioning of the Jenkins

Documentation is in [the main README of the repo].

## How to set up a job using Jenkinsfile

This is an [example of a project] that can be built using this Jenkins platform - there you can see
how we defined its [Jenkinsfile].

You can build that project by running the `build-sample-java-app` job, which should be in your Jenkins by default.

There are a number of steps to set up a job using Jenkinsfile:

* Build a Docker image for the Jenkins agent

* Publish the Docker image

* Setup a Docker Cloud in Jenkins

* Specify the Docker Cloud in the Jenkinsfile

* Create the Jenkins job

Let's describe them one by one.

### Build a Docker image for the Jenkins agent

The Docker container of your Jenkins agent has two responsibilities:

* communicating with the Jenkins master

* carrying out the work specified by the job

Therefore, we will need to have two sets of software installed on it:

* the official Jenkins agent components

* all the tools needed to execute the Jenkins job - e.g. JDK, Ruby, ... - we can call this `toolchain`

As a container can inherit from only one image, we have two possibilities:

#### Build the container based on the Jenkins slave

The Jenkins software depends on Java, so the `jenkins/jnlp-slave` image already installs the JDK for Java 8, using Debian 9 as operating system (at the time of writing).

This is an example of a Docker image for Maven:

```
FROM jenkins/jnlp-slave

ARG user=jenkins

USER root

# install Maven

ARG MAVEN_VERSION=3.5.3
ARG USER_HOME_DIR="/root"
ARG SHA=b52956373fab1dd4277926507ab189fb797b3bc51a2a267a193c931fffad8408
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN apt-get update && \
    apt-get install -y \
      curl procps \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

USER ${user}

ENV LC_ALL en_GB.UTF-8
CMD ["/bin/bash"]
```

#### Build the container based on the toolchain

* Inherit and build your toolchain:

```
FROM ruby

RUN apt update
RUN apt install -y ruby-dev
RUN apt install -y bundler
[reducted]
```

* On top of it, install JDK 8, as it is needed by the Jenkins software - obviously you don't need this step if your toolchain already had the JDK 8.

* Append these lines to install the Jenkins software (provided the base image is based on Debian or Ubuntu):

```
ARG user=jenkins
ARG group=jenkins
ARG uid=10000
ARG gid=10000

USER root
ENV HOME /home/${user}
RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}

ARG VERSION=3.20
ARG AGENT_WORKDIR=/home/${user}/agent
RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}
VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

USER root
RUN curl --create-dirs -SLo /usr/local/bin/jenkins-slave https://raw.githubusercontent.com/jenkinsci/docker-jnlp-slave/master/jenkins-slave \
  && chmod 755 /usr/local/bin/jenkins-slave

USER ${user}
ENTRYPOINT ["/usr/local/bin/jenkins-slave"]
```

### Publish the Docker image

After building the image, you have to publish it to a repository (e.g. Docker Hub) so that it can be referenced from Jenkins.

### Setup a Docker Cloud in Jenkins

A Docker Cloud is

Your new Docker Cloud can be defined using the [template file].
Please make a copy of that file and edit it to your own specification. There are four variables that need adjusting:

* image - The identifier of the image you have published in the previous step
* labelString - Must match the agent:label in the Jenkinsfile of your app
* name - Name of this Docker Cloud
* serverUrl - URI to the Docker Host you are using (probably you don't need to change this).

These are all labelled 'custom' within the template file.

For extra guidance on using Jenkins' Docker plugin visit their [help page].

### Specify the Docker Cloud in the Jenkinsfile

At the top of the Jenkinsfile of the project you want to add a line like this, based on the label you chose at the previous step:

```
agent {
    label 'sample-docker-jnlp-java-agent'
}
```

### Create the Jenkins job

Then, the last part is to create a new job that will use the Jenkinsfile of the repository.
From Jenkins, 'New item' -> 'Pipeline'. Then, the settings are as follows:

* Github project URL: [git-repo-url]
* Pipeline Definition: Pipeline script from SCM Pipeline
* SCM: Git
* Pipeline Repository URL: [git-repo-url]

## Known bugs

As it stands Docker configuration is loaded from a git branch specified in the [cloud init yaml file]. If you make changes to your Docker config, including adding an image as in the instructions above, you must make sure that your changes are pushed to a branch on git. Before running a `terraform apply` you will need to update the [Jenkins variables file] with the name of your working branch rather than master. In this way the name of your working branch need never be committed to git. We are planning on automating this process.

## Decommissioning of the Jenkins

There are 4 steps to decommission the Jenkins platform for one of your environments:

* decommissioning the Jenkins infrastructure, via `terraform destroy`

* decommissioning the DNS infrastructure, via `terraform destroy`

* deleting the S3 buckets used for the Terraform state files

* deleting the Github OAuth app

### Before you start

1. Move to the directory in which you cloned the repository originally.\
If you don't have it anymore, clone the repository again and customise the `terraform.tfvars`
as you did during the provisioning steps, for both the `terraform\dns` and `terraform\jenkins` directories.

1. Make sure you still have this in `~/.aws/credentials`, otherwise add it again:

       ```
       [re-build-systems]
       aws_access_key_id = [your aws key here]
       aws_secret_access_key = [your aws secret here]
       ```

1. Export those credentials

   If you are using bash, then add a space at the start of export AWS_ACCESS_KEY_ID and export AWS_SECRET_ACCESS_KEY to prevent them from being added to ~/.bash_history.

   ```
   export AWS_ACCESS_KEY_ID="[aws key]"
   export AWS_SECRET_ACCESS_KEY="[aws secret]"
   export AWS_DEFAULT_REGION="eu-west-1"
   ```

1. Export these environment variables

    ```
    export JENKINS_ENV_NAME=[environment-name]
    export JENKINS_TEAM_NAME=[team-name]
    ```

### Decommissioning the Jenkins infrastructure

1. Run this from the `terraform/jenkins` directory:

    ```
    terraform destroy \
        -var environment=$JENKINS_ENV_NAME \
        -var-file=./terraform.tfvars \
        -var ssh_public_key_file=~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa.pub
    ```

    The previous `terraform destroy` command may fail to delete everything on the first run. If so, just run it again.

    There is also a chance that this will fail and ask you to run a `terraform init`. If this happens then run the following command before trying to destroy again.

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
    ```

### Decommissioning the DNS infrastructure

1. Run this from the `terraform/dns` directory:

    ```
    terraform destroy -var-file=./terraform.tfvars
    ```

    The previous `terraform destroy` command may fail to delete everything on the first run. If so, just run it again.

    There is also a chance that this will fail and ask you to run a `terraform init`. If this happens then run the following command before trying to destroy again.

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
        -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
    ```

### Deleting the Terraform state S3 buckets

1. Make sure you have `jq` (version `> 1.5.0`) installed

1. Run these commands from the `tools` directory:

    ```
    ./delete-s3-bucket tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering
    ```

    ```
    ./delete-s3-bucket tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME
    ```

### Deleting the Github OAuth app

Go to [Github developer settings] > `OAuth Apps` > Select the app > `Delete application`


[the main README of the repo]: https://github.com/alphagov/re-build-systems
[example of a project]: https://github.com/alphagov/re-build-systems-sample-java-app/tree/jenkinsfile-supported-by-re-build-mvp
[Jenkinsfile]: https://jenkins.io/doc/book/pipeline/jenkinsfile/
[template file]: /docker/files/groovy/add-sample-agent-docker-image.groovy
[cloud init yaml file]: /terraform/jenkins/cloud-init/server-asg-xenial-16.04-amd64-server.yaml
[Jenkins variables file]: /terraform/jenkins/variables.tf
[help page]: https://wiki.jenkins.io/display/JENKINS/Docker+Plugin
[Github developer settings]: https://github.com/settings/developers
