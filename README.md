# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a containerised Jenkins platform on AWS, consisting of a master node and an agents node (see the architectural section below for more details).

## Architectural documentation

Architectural documentation is available [here](docs/architecture/README.md).


## Provisioning Jenkins2 on AWS


### Before you start

Things you need to decide upon:

* The URL for your Jenkins website

* The AWS account in which you want to provision the platform (we create a dedicated VPC)

* An environment name, which will be referred as `[environment-name]` from now on.
  That is usually something like `test`, `staging`, `production` or your name if you are doing development or testing (e.g. `daniele`). 

* The Github team(s) you want to allow access to your Jenkins installation

* The administrator(s) of the Jenkins installation

Things you will need to have:

* An AWS user account with programmatic access - the account will need to be able to create S3 buckets, EC2 instances, VPCs, DNS records and security groups.

* Dependencies installed on your laptop:

    * Terraform v0.11.7

    * `brew install awscli python3`

* Request a Github OAuth application to be created. The RE team can do that for you - you only need to provide the URL you have decided to use for your Jenkins.
You will receive an `id` and `secret` you will need to use later on.

### Provisioning steps

1. Currently, the AWS user credentials need to be stored in `~/.aws/credentials`, like so:

    ```
    [re-build-systems]
    aws_access_key_id = [aws-key]
    aws_secret_access_key = [aws-secret]
    ```

1. Check out this repository.

1. Check out [this other repository](https://github.com/alphagov/re-build-systems-config) which contains configuration

    The two working copies should live in the same directory, like so:
    
        ```
        |-- re-build-systems
        |-- re-build-systems-config
        ```

1. Copy your SSH **public** key to the `re-build-system-config`/`terraform`/`keys` folder with this name: `re-build-systems-[environment-name]-ssh-deployer.pub`.

1. In the configuration folder, customise the `terraform.tfvars` file, in particular these entries:
    * `github_client_id`, `github_client_secret` as you got them when the Github OAuth app was created
    * `github_organisation` is the list of Github teams you want to grant access to your Jenkins installation
    * `github_admin_users` is the list of administrators (use their Github usernames)

1. Create an S3 bucket to host the terraform state file:

    ```
    cd [the_working_copy_of_this_repo]
    terraform/tools/create-s3-state-bucket -b re-build-systems -e [environment-name] -p re-build-systems
    ```

1. Export secrets

    In order to initialise the S3 bucket we have created with Terraform, we need to export some secrets:

    ```
    export AWS_ACCESS_KEY_ID="[aws-key]"
    export AWS_SECRET_ACCESS_KEY="[aws-secret]"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

1. Run Terraform

    ```
    cd terraform
    terraform init -backend-config="region=eu-west-2" -backend-config="bucket=tfstate-re-build-systems-[environment-name]" -backend-config="key=re-build-systems.tfstate"
    terraform apply -var-file=../../re-build-systems-config/terraform/terraform.tfvars  -var environment=[environment-name]
    ```

1. Use the new Jenkins instance

    The previous `terraform apply` outputs some values. The most useful are the `jenkins2_eip` and `public_dns_name` (values of these are printed in bold in the example output above).

    * Visit the Jenkins installation at the URL you decided to use

    * SSH into the instance with `ssh -i [path-to-your-private-ssh-key] ubuntu@[jenkins2_eip]`
        * To switch to the root user, run `sudo su -`

### Recommendations

This is a list of things you may consider doing next:

* implement HTTPS
* enable AWS CloudTrail
* remove the default `ubuntu` account from the AWS instance(s)


## Provisioning Jenkins2 on your laptop for development

This section is relevant only if you are interested in develop this project.

This will provision a Docker container running Jenkins2 on your laptop.

You need `docker` >= `v18.03.0`

```
cd docker
docker build -t="jenkins/jenkins-re" .
docker run --name myjenkins -ti -p 8000:80 -p 50000:50000 jenkins/jenkins-re:latest
```

To access the instance browse to [here](http://localhost:8000)


For debugging, you can either:

* access container as jenkins user:
`docker exec -u 1000 -it myjenkins /bin/bash`

* access container as root user:
`docker exec -it myjenkins /bin/bash`

## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)
