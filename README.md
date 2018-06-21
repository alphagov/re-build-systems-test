# Reliability Engineering - Build Systems

This repository provides the infrastructure code for provisioning a containerised Jenkins 2 platform on AWS, consisting of a master node and an agents node (see the section on architectural documentation below for more details).

## Architectural documentation

Architectural documentation is available [here](docs/architecture/README.md).


## Provisioning Jenkins on AWS


### Prerequisites

    * `terraform` `=` `0.11.7`

    * `python` `>=` `2.7`

    * `awscli`


### Provisioning steps

1. Add your AWS user credentials to `~/.aws/credentials`, like so:

    ```
    [re-build-systems]
    aws_access_key_id = [your aws key here]
    aws_secret_access_key = [your aws secret here]
    ```

1. Generate an SSH key pair in a location of your choice.

    You can use this command to generate one:

    ```
    ssh-keygen -t rsa -b 4096 -C "[key comment]"
    ```

    We suggest the `key comment` to contain the name of your team and the environment name.

    The public key will only be used later on in these steps.

    The private key will need to be shared amongst the team, to allow them to SSH into the servers.

1. If not done already, clone this repository in a location of your choice.

1. In the `terraform` folder, rename `terraform.tfvars.example` to `terraform.tfvars`.

1. Customise the `terraform.tfvars` file, in particular these entries:
    * `allowed_ips` the IPs you want to allow access to your Jenkins - consult the user manual if you have one
    * `github_client_id`, `github_client_secret` as they were given to you when the Github OAuth app was created
    * `github_organisation` is the list of the Github teams you want to grant access to your Jenkins
    * `github_admin_users` is the list of the Github usernames who will become Jenkins administrators
    * `hostname_suffix` is your hostname suffix
    * `team` is your team name

1. For convenience, export the environment name, so that you won't need to type it in the next steps:

    ```
    export JENKINS_ENV_NAME=[environment-name]
    ```

    This is usually something like test, staging, production, or your name if you are doing development.

1. Create an S3 bucket to host the terraform state file.

    From the root of your working copy run

    ```
    terraform/tools/create-s3-state-bucket \
        -b re-build-systems \
        -e $JENKINS_ENV_NAME \
        -p re-build-systems
    ```

1. Export secrets

    In order to initialise the S3 bucket we have created with Terraform, we need to export some secrets:

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

1. Run Terraform

    ```
    cd terraform
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="key=re-build-systems.tfstate" \
        -backend-config="bucket=tfstate-re-build-systems-$JENKINS_ENV_NAME"
    ```

    ```
    terraform apply \
        -var-file=./terraform.tfvars  \
        -var environment=$JENKINS_ENV_NAME \
        -var ssh_public_key_file=[path to your public ssh key]
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
