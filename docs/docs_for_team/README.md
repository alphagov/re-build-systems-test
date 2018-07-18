# Documentation for the product team

## Provisioning of the Jenkins

Documentation is in [the main README of the repo](https://github.com/alphagov/re-build-systems-dns).

## How to set up a job using Jenkinsfile

This is an [example of a project](https://github.com/alphagov/re-build-systems-sample-java-app/tree/jenkinsfile-supported-by-re-build-mvp) that can be built using this Jenkins platform.

It shows how to structure the Jenkinsfile - the most important part is this:

```
agent {
    label 'docker-jnlp-java-agent'
}
```

`docker-jnlp-java-agent` is an the Docker  image you define in Jenkins, via
'Manage Jenkins' -> 'Configure system' -> 'Cloud' -> 'Add a new cloud'.
The settings are:

* Name: docker-worker-2-java
* Docker Host URI: tcp://worker:2375
* Label: docker-jnlp-java-agent
* Docker image: [builder-docker-image-url]
* Remote filesystem root: /home/jenkins
* Connect method: Attach Docker container

That can also be done via a Groovy script.

`builder-docker-image-url` is the URL of the Docker image which is going to build the code (for example, it may be hosted on Dockerhub).

The way you build the image is by inheriting from the `jenkins/jnlp-slave` base image and install
your development tools on top of it.

This is an example of a builder Docker image for Maven (bear in mind that the Jenkins slave image installs Java8):

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

Then, the last part is to create a new job that will use the Jenkinsfile of the repository.
From Jenkins, 'New item' -> 'Pipeline'. Then, the settings are as follows:

* Github project URL: [git-repo-url]
* Pipeline Definition: Pipeline script from SCM Pipeline
* SCM: Git
* Pipeline Repository URL: [git-repo-url]

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

### Decommissioning the DNS infrastructure

1. Run this from the `terraform/dns` directory:

    ```
    terraform destroy -var-file=./terraform.tfvars
    ```

    The previous `terraform destroy` command may fail to delete everything on the first run. If so, just run it again.

### Deleting the Terraform state S3 buckets

1. Make sure you have `jq` (version `> 1.5.0`) installed

1. Run these commands from anywhere:

    ```
    aws s3api delete-objects \
      --bucket tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering \
      --delete "$(aws s3api list-object-versions --bucket tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering | jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')"
    ```

    ```
    aws s3api delete-objects \
          --bucket tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME \
          --delete "$(aws s3api list-object-versions --bucket tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME | jq '{Objects: [.Versions[] | {Key:.Key, VersionId : .VersionId}], Quiet: false}')"
    ```

### Deleting the Github OAuth app

Go to [Github developer settings](https://github.com/settings/developers) > `OAuth Apps` > Select the app > `Delete application`
