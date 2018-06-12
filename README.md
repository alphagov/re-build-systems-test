# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a containerised Jenkins 2 platform on AWS, consisting of a master node and an agents node (see the section on architectural documentation below for more details).

## Architectural documentation

Architectural documentation is available [here](docs/architecture/README.md).


## Provisioning Jenkins on AWS


### Before you start

Decide on the:

* URL for your Jenkins website

* AWS account in which you want to provision the platform (provisioning this infrastructure will create a dedicated VPC)

* Environment name, which will be referred as `[environment-name]` from now on.
  This is usually something like `test`, `staging`, `production`, or `your name` if you are doing development.

* Teams you want to access your Jenkins

* People you want to be administrators of your Jenkins

Make sure you have:

* An AWS user account with programmatic access - this account will need to be able to create S3 buckets, EC2 instances, VPCs, DNS records and security groups.

* The following dependencies installed on your laptop:

    * `terraform` `>=` `0.11.7`

    * `python` `>=` `2.7`
    
    * `awscli`

* Ask RE to create a Github OAuth application for you. You need to provide the URL you have decided to use for your Jenkins.
You will receive an `id` and `secret` you will need later on.

### Provisioning steps

1. Add the AWS user credentials to `~/.aws/credentials`, like so:

    ```
    [re-build-systems]
    aws_access_key_id = [your-aws-key-here]
    aws_secret_access_key = [your-aws-secret-here]
    ```

1. Clone this repository.

1. Clone [this other repository](https://github.com/alphagov/re-build-systems-config) which contains configuration

    The two working copies should live in the same directory, like so:
    
        ```
        |-- re-build-systems
        |-- re-build-systems-config
        ```

1. Copy your SSH **public** key to the `re-build-system-config`/`terraform`/`keys` folder with this name: `re-build-systems-[environment-name]-ssh-deployer.pub`.

    If you don't have an SSH key, generate one like so:

    ```
    ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
    ```

1. In the configuration folder, customise the `terraform.tfvars` file, in particular these entries:
    * `github_client_id`, `github_client_secret` as they were given to you when the Github OAuth app was created
    * `github_organisation` is the list of the Github teams you want to grant access to your Jenkins
    * `github_admin_users` is the list of the Github usernames who will become Jenkins administrators
    * `product` is used as a tag for the resources created on AWS - it can be anything you like

1. Create an S3 bucket to host the terraform state file:

    Move back to the working copy of the main repository (this one, not the configuration one), and run

    ```
    terraform/tools/create-s3-state-bucket \
        -b re-build-systems \
        -p re-build-systems \
        -e [environment-name]
    ```

1. Export secrets

    In order to initialise the S3 bucket we have created with Terraform, we need to export some secrets:

    ```
    export AWS_ACCESS_KEY_ID="[aws-key]"
    export AWS_SECRET_ACCESS_KEY="[aws-secret]"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

1. Run Terraform

    In the following commands, replace the `[environment-name]` placeholder

    ```
    cd terraform
    ```
    
    ```
    terraform init \
        -backend-config="region=eu-west-2" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-re-build-systems-[environment-name]"
    ```
    
    ```
    terraform apply \
      -var-file=../../re-build-systems-config/terraform/terraform.tfvars  \
      -var environment=[environment-name]
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
ssh -i [path-to-your-private-ssh-key] ubuntu@[jenkins2_eip]
```

To SSH into the agents instance you need to use the master node as a proxy, like so:
```
ssh -i [path-to-your-private-ssh-key] -o ProxyCommand='ssh -W %h:%p ubuntu@[jenkins2_eip]' ubuntu@[jenkins2_worker_private_ip]
```

Once logged in with the `ubuntu` user, you can switch to the root user by running `sudo su -`.

### Recommendations

Next, you may want to:

* implement HTTPS
* enable AWS CloudTrail
* remove the default `ubuntu` account from the AWS instance(s)


## Provisioning Jenkins on your laptop for development

This section is relevant only if you are interested in developing this project.

You need `docker` >= `v18.03.0`.

These commands provision a Docker container running Jenkins on your laptop.

```
cd docker
docker build -t="jenkins/jenkins-re" .
docker run --name myjenkins -ti -p 8000:80 -p 50000:50000 jenkins/jenkins-re:latest
```

To access the Jenkins browse to [here](http://localhost:8000)


For debugging, you can either:

* access the container as jenkins user:
`docker exec -u 1000 -it myjenkins /bin/bash`

* access the container as root user:
`docker exec -it myjenkins /bin/bash`

## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)
