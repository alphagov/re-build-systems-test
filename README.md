# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a containerised Jenkins instance on either a laptop or AWS.


## Architectural documentation

Architectural documentation is available [here](docs/architecture/README.md).


## Provisioning Jenkins2 on AWS

This is to provision a containerized Jenkins platform on AWS, within a master node and an agents node (see architectural section about for more details).

### Before you start

Things you need to decide upon:

* the URL for your Jenkins website

* the AWS account you want to provision the platform in (we create a dedicated VPC for the Jenkins components)

* an environment name, which will be referred as `[environment-name]` from now on.
  That is usually something like `test`, `staging`, `production` or your name if you are doing development or testing (e.g. `daniele`). 

* who is going to be an administrator of the Jenkins system

Things you will need to have:

* an AWS user account

* dependencies installed on your laptop:

    * Terraform v0.11.7

    * `brew install awscli python3`

* request a Github OAuth application to be created. The RE team can do that for you - you only need to provide the URL you have decided to use for your Jenkins.
You will receive an `id` and `secret` you will need to use later on.

### Provisioning steps

1. Checkout this repository.

1. Configure your ~/.aws/credentials file with your own details:

    ```
    [re-build-systems]
    aws_access_key_id = AABBCCDDEEFFG
    aws_secret_access_key = abcdefghijklmnopqrstuvwxyz1234567890
    ```

    Be careful not to use quotes in the above.

1. Have a "configuration directory" with this structure:

    ```
    |-- re-build-system            <-- this repository
    |-- re-build-system-config     <-- configuration folder
    |   |-- terraform
    |       |-- keys
    |       |-- terraform.tfvars

    ```
    
    If you are from GDS, you can simply checkout [this repo](https://github.com/alphagov/re-build-systems-config) as your config folder. 

1. Generate an SSH public/private key pair (w/o a passphrase) - this is just to bootstrap the provisioning process:
    ``` 
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```

1. Copy the **public** key you generated to the `re-build-system-config`/`terraform`/`keys` folder, using this name: `re-build-systems-[environment-name]-ssh-deployer.pub`.

1. In the configuration folder, customise the `terraform.tfvars` file, in particular the items related to `github`:
    * `github_client_id`, `github_client_secret` should have been given to you when a Github OAuth app was created
    * `github_organisation` is the list of Github teams you want to grant access to your Jenkins installation
    * `github_admin_users` is the list of administrators (use their Github usernames)

1. Create an S3 bucket to host terraform state file:

    ```
    cd [your_git_working_copy]
    terraform/tools/create-s3-state-bucket -b re-build-systems -e [environment-name] -p re-build-systems
    ```

1. Export secrets

    In order to initialise with Terraform the S3 bucket we have created, we need to export some secrets from the `~/.aws/credentials` file.

    ```
    export AWS_ACCESS_KEY_ID="someaccesskey"
    export AWS_SECRET_ACCESS_KEY="mylittlesecretkey"
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
