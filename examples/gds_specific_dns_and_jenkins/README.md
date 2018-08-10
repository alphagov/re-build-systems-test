# Example configuration

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
`https://[server_name].[environment].[team_name].build.gds-reliability.engineering`

## Provision the DNS infrastructure

Provisioning the DNS infrastructure allows you to set up the URLs you will use to access your Jenkins.

You will have to provision a separate Jenkins for each environment. For example, you might want separate 'development' and 'production' environments. These environments will have different URLs.

You can start by provisioning the DNS for one environment and add other environments later.

For this step, you will need to choose your team name, which will be part of the Jenkins URL.

1. Add your AWS user credentials to ~/.aws/credentials

	If this file does not exist, create it first.

	```
	[my-aws-profile]
	aws_access_key_id = [your aws key here]
	aws_secret_access_key = [your aws secret here]
	```

1. Set AWS environment variables

	```
	export AWS_ACCESS_KEY_ID="[aws key]"
	export AWS_SECRET_ACCESS_KEY="[aws secret]"
	export AWS_DEFAULT_REGION="[aws region]"
	```

1. Set Jenkins related environment variables

	```
	export JENKINS_TEAM_NAME="[my-team-name]"
	```

1. Create the S3 bucket to host the terraform state file using the create-dns-s3-state-bucket script in the tools directory 

	```
	cd examples/gds_specific_dns_and_jenkins/dns
	../../../tools/create-dns-s3-state-bucket \
	  -d build.gds-reliability.engineering \
	  -p my-aws-profile \
	  -t $JENKINS_TEAM_NAME
	```

1. Using the `terraform.tfvars.example` file as a template create a terraform.tfvars file

	```
	cp terraform.tfvars.example terraform.tfvars
	vim terraform.tfvars
	```

	| Name | Var Type | Required | Default | Description |
	| :--- | :--- | :--: | :--- | :--- |
	| `aws_profile` | string | | default aws profile in ~/.aws/credentials | AWS Profile (credentials) to use |
	| `aws_region` | string | | default aws region | AWS Region to use, eg. eu-west-1 |
	| `hostname_suffix` | string | **yes** | none | Main domain name for new Jenkins instances, for GDS use build.gds-reliability.engineering |
	| `team_name` | string | **yes** | none | Name of your team. This is used to construct the DNS name for your Jenkins instances |

1. Initialise terraform

	```
	terraform init \
	  -backend-config="region=$AWS_DEFAULT_REGION" \
	  -backend-config="bucket=tfstate-dns-$JENKINS_TEAM_NAME.build.gds-reliability.engineering" \
	  -backend-config="key=$JENKINS_TEAM_NAME.build.gds-reliability.engineering.tfstate"
	```

1. Apply terraform to configure

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

	Copy and send this output to the GDS Reliability Engineering team, which will make your URL live.
	This step may take up to two working days, if you progress to the next step before awaiting confirmation from the GDS Reliability Engineering team your *.build.gds-reliability.engineering domain will not be configured and cause errors when generating the TLS certificate used for HTTPS.

## Provision the main Jenkins infrastructure

Once RE complete those tasks and come back to you, you can then move to this.

In this step you will provision all the infrastructure needed to run your Jenkins.

For this step, you will need to choose which environment you want to set up Jenkins for
(e.g. `ci`, `dev`, `staging`) - that will be part of the URL of your Jenkins.

1. Create a Github OAuth app

	This allows you to use Github for logging in to Jenkins.

	Go to the [Register a new OAuth application](https://github.com/settings/applications/new) and use the following settings to setup your app.

	The [URL] will follow the pattern `https://[server_name].[environment].[team_name].[hostname_suffix]`.  For example `https://jenkins2.dev.my-team.build.gds-reliability.engineering`

	* Application name:  `jenkins-[environment]-[team_name]` , e.g. `jenkins-dev-my-team`.

	* Homepage URL:  `[URL]`

	* Application description:  `Build system for [URL]`

	* Authorization callback URL:  `https://[server_name].[environment].[team_name].[hostname_suffix]/securityRealm/finishLogin`

	Then, click the 'Register application' button.

	Export the credentials as they appear on the screen:

	```
	export JENKINS_GITHUB_OAUTH_ID="[client-id]"
	export JENKINS_GITHUB_OAUTH_SECRET="[client-secret]"
	```

1. Set Jenkins related environment variables

	```
	export JENKINS_TEAM_NAME="[my-team-name]"
	export JENKINS_ENV_NAME="[my-environment]"
	```

1. Set AWS environment variables

	```
	export AWS_ACCESS_KEY_ID="[aws key]"
	export AWS_SECRET_ACCESS_KEY="[aws secret]"
	export AWS_DEFAULT_REGION="[aws region]"
	```

1. Create the S3 bucket to host the terraform state file using the create-s3-state-bucket script in the tools directory

	```
	cd examples/gds_specific_dns_and_jenkins/jenkins
	../../../tools/create-s3-state-bucket \
	  -t $JENKINS_TEAM_NAME \
	  -e $JENKINS_ENV_NAME \
	  -p my-aws-profile
	```


1. Using the terraform.tfvars.example file as a template create a terraform.tfvars file

	```
	cp terraform.tfvars.example terraform.tfvars
	vim terraform.tfvars
	```

	| Name | Var Type | Required | Default | Description |
	| :--- | :--- | :--: | :--- | :--- |
	| `allowed_ips` | list | **yes** | none | A list of IP addresses permitted to access (via SSH & HTTPS) the EC2 instances created that are running Jenkins |
	| `aws_az` | string | | the first AZ in a region | Single availability zone to place master and worker instances in, eg. eu-west-1a |
	| `aws_profile` | string | | default aws profile in ~/.aws/credentials | AWS Profile (credentials) to use |
	| `aws_region` | string | | default aws region | AWS Region to use, eg. eu-west-1 |
	| `docker_version` | string | **yes** | none | The version of docker to install |
	| `environment` | string | **yes** | none | Environment name (e.g. production, test, ci). This is used to construct the DNS name for your Jenkins instances |
	| `github_admin_users` | list | | none | List of Github admin users (github user name) |
	| `github_client_id` | string | | none | Your Github Auth client ID |
	| `github_client_secret` | string | | none | Your Github Auth client secret |
	| `github_organisations` | list | | none | List of Github organisations and teams that users must be a member of to allow HTTPS login to master |
	| `gitrepo` | string | | https://github.com/alphagov/re-build-systems.git | Git repo that hosts Dockerfile |
	| `gitrepo_branch` | string | | master | Branch of git repo that hosts Dockerfile |
	| `hostname_suffix` | string | **yes** | none | Main domain name for new Jenkins instances, eg. example.com |
	| `jenkins_version` | string | | latest | Version of jenkins to install |
	| `server_instance_type` | string | | t2.small | This defines the default master server EC2 instance type |
	| `server_name` | string | | jenkins2 | Hostname of the jenkins2 master |
	| `server_root_volume_size` | string | | 50 | Size of the Jenkins Server root volume (GB) |
	| `ssh_public_key_file` | string | **yes** | none | Location of public key used to access the server instances |
	| `team_name` | string | **yes** | none | Name of your team. This is used to construct the DNS name for your Jenkins instances |
	| `ubuntu_release` | string | | xenial-16.04-amd64-server | Which version of ubuntu to install |
	| `worker_instance_type` | string | | t2.medium | This defines the default worker server EC2 instance type |
	| `worker_name` | string | | worker | Name of the Jenkins2 worker |
	| `worker_root_volume_size` | string | | 50 | Size of the Jenkins worker root volume (GB) |

1. Initialise terraform

	```
	terraform init \
	  -backend-config="region=$AWS_DEFAULT_REGION" \
	  -backend-config="key=re-build-systems.tfstate" \
	  -backend-config="bucket=tfstate-$JENKINS_TEAM_NAME-$JENKINS_ENV_NAME"
	```

1. Plan and Apply terraform

	```
	terraform plan \
	  -var-file=./terraform.tfvars  \
	  -var environment=$JENKINS_ENV_NAME \
	  -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
	  -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
	  -out my-plan.txt
	```

	```
	terraform apply \
	  -var-file=./terraform.tfvars  \
	  -var environment=$JENKINS_ENV_NAME \
	  -var github_client_id=$JENKINS_GITHUB_OAUTH_ID \
	  -var github_client_secret=$JENKINS_GITHUB_OAUTH_SECRET \
	  my-plan.txt
	```

## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)
