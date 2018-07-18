# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a Jenkins build system. This build system is a containerised Jenkins (version 2) platform
on AWS, consisting of a master node and an agent node. Once provisioned, users log into the Jenkins using their Github account.

If you would like more information about the architecture of this build system, you can read the [architectural documentation](docs/architecture/README.md).


## Prerequisites

You will need:

* basic understanding of how to use Terraform

* an AWS user account with administrator access

* the following software installed on your laptop:
    * terraform v0.11.7
    * awscli

## Overview

This documentation will lead you through three steps to set up your Jenkins platform:

* provision the DNS infrastructure (only the first time)

* provision the main Jenkins infrastructure (for each environment you want to provision)

* log in to your new Jenkins and try it out

You need to provision the DNS infrastructure only once, and have the Reliability Engineering team enable your new domain (you may have to wait up to two working days for that).
Then, you can provision the main Jenkins infrastructure anytime you need to create a new environment.

For each environment you create the associate URL will be in this form:
`https://jenkins2.[environment_name].[team_name].build.gds-reliability.engineering`

## Provision the DNS infrastructure

Provisioning the DNS infrastructure allows you to set up the URLs you will use to access your Jenkins.

You will have to provision a separate Jenkins for each environment. For example, you might want separate 'development' and 'production' environments. These environments will have different URLs.

You can start by provisioning the DNS for one environment and add other environments later.

For this step, you will need to choose your team name, which will be part of the Jenkins URL.

1. Add your AWS user credentials to `~/.aws/credentials`

  If this file does not exist, create it first.

    ```
    [re-build-systems]
    aws_access_key_id = [your aws key here]
    aws_secret_access_key = [your aws secret here]
    ```

1. Clone this repository to a location of your choice.

1. Go to the `terraform/dns` folder and rename `terraform.tfvars.example` to `terraform.tfvars`.

1. Go into the `terraform.tfvars` file you just renamed and customise the user settings under `### CUSTOM USER SETTINGS ###`.

1. Export the `team_name` as a variable to use when running the DNS Terraform

    ```
    export JENKINS_TEAM_NAME=[your team name as defined in the `terraform.tfvars` file]
    ```

1. Create the S3 bucket to hold the Terraform state file.

   Run this command from the `terraform/dns/tools` directory:

    ```
    ./tools/create-dns-s3-state-bucket \
        -d build.gds-reliability.engineering \
        -p re-build-systems \
        -t $JENKINS_TEAM_NAME
    ```

    If you receive an error, it may be because your `team_name` is not unique, which it must be to ensure that URLs are unique. Go back to point 4 in the previous (Configure DNS) section, change your `team_name` and then continue from there.

1. Export secrets

    In order to initialise the S3 bucket, you need to export secrets from the `~/.aws/credentials` file.

    If you are using bash, then add a space at the start of `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` to prevent them from being added to `~/.bash_history`.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-1"
    ```

1. Provision the DNS

   Run these commands from the `terraform/dns` directory:

    ```        
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
        -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
    ```

    ```
    terraform apply -var-file=./terraform.tfvars
    ```

1. You will get an output in your terminal that looks like this:

    ```
    Outputs:

    team_domain_name = [team_name].build.gds-reliability.engineering
    team_zone_id = A1AAAA11AAA11A
    team_zone_nameservers = [
        ns-1234.awsdns-56.org,
        ns-7890.awsdns-12.co.uk,
        ns-345.awsdns-67.com,
        ns-890.awsdns-12.net
    ]
    ```

    Copy and send this output to the GDS Reliability Engineering team.

    The Reliability Engineering team will make your URL live and set up your Github OAuth so you can log in to your Jenkins.

    This step may take up to two working days.




## Provision the main Jenkins infrastructure

Once RE complete those tasks and come back to you, you can then move to this.

In this step you will provision all the infrastructure needed to run your Jenkins.

For this step, you will need to choose which environment you want to set up Jenkins for
(e.g. `ci`, `dev`, `staging`) - that will be part of the URL of your Jenkins.

1. Export the environment and team names, as you set them during the provisioning of the DNS:

    ```
    export JENKINS_ENV_NAME=[environment-name]
    export JENKINS_TEAM_NAME=[team-name]
    ```

1. Generate an SSH key pair in a location of your choice.

    You can use this command to generate one:

    ```
    ssh-keygen -t rsa -b 4096 \
        -C "Key for Build System - team ${JENKINS_TEAM_NAME} - environment ${JENKINS_ENV_NAME}" \
        -f ~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa
    ```

    The public key will be used in a later step.

    The private key will need to be shared amongst the team, to allow them to SSH into the servers.

1. In the `terraform/jenkins` folder, rename `terraform.tfvars.example` to `terraform.tfvars`.

1. Customise the `terraform.tfvars` file by editing the settings under `## CUSTOM USER SETTINGS - change these values for your custom Jenkins ###`

1. Create an S3 bucket to host the terraform state file.

    Run this command from the `terraform/jenkins/tools` directory:

    ```
    ./create-s3-state-bucket \
        -t $JENKINS_TEAM_NAME \
        -e $JENKINS_ENV_NAME \
        -p re-build-systems
    ```

1. Export secrets

    In order to initialise the S3 bucket we have created with Terraform, we need to export some secrets.

    You did this in the `Run DNS Terraform` section of this guidance, so you only need to carry out this step if you ended your terminal session since you carried out that step.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-1"
    ```

1. Run these commands from the `terraform/jenkins` directory:

    ```
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
    ```
    If you did not use our suggested command to create the SSH key pair, make sure you change the below command to reflect the file path to your public SSH key:
    ```
    terraform apply \
        -var-file=./terraform.tfvars  \
        -var environment=$JENKINS_ENV_NAME \
        -var ssh_public_key_file=~/.ssh/build_systems_${JENKINS_TEAM_NAME}_${JENKINS_ENV_NAME}_rsa.pub
    ```

    You may want to take note of these values from the output of the previous command - they can be helpful for debugging:

    * `jenkins2_eip` - the public elastic IP of the master node

    * `jenkins2_worker_private_ip` - the private IP of the agents node

    If you get this `Error loading modules: bad response code: 401` when running the `terraform init` command,
    that may be because of the content in your `.netrc` file. To work around that,
    you can temporarily rename the file, so that `terraform` will ignore it.    

1. Use the new Jenkins

    Visit the Jenkins at the URL you decided to use

### Debugging

To SSH into the master instance run:
```
ssh -i [path-to-the-private-ssh-key-you-generated] ubuntu@[jenkins2_eip]
```

To SSH into the agents instance you need to use the master node as a proxy, like so:
```
ssh -i [path-to-the-private-ssh-key-you-generated] -o ProxyCommand='ssh -W %h:%p ubuntu@[jenkins2_eip]' ubuntu@[jenkins2_worker_private_ip]
```

Once logged in with the `ubuntu` user, you can switch to the root user by running `sudo su -`.

### Recommendations

Next, you may want to:

* implement HTTPS
* enable AWS CloudTrail
* remove the generic SSH key used during provisioning and use personal keys
* remove the default `ubuntu` account from the AWS instance(s)


## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)
