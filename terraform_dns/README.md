# Reliability Engineering - Build Systems - Team DNS and EIP Configuration

It will configure a teams subdomain and EIP, which will allow them to remain persistent as they will be maintained within their own state file.

## Prerequisites

    * terraform = 0.11.7

    * python >= 2.7

    * awscli

## Configuration

1. Add your AWS user credentials to `~/.aws/credentials`, like so:

    ```
    [re-build-systems]
    aws_access_key_id = [your aws key here]
    aws_secret_access_key = [your aws secret here]
    ```

1. Clone this repository in a location of your choice.

1. In the `terraform_dns` folder, rename `terraform.tfvars.example` to `terraform.tfvars`.

1. In the file you just renamed, customise the settings in the `### USER SETTINGS ###` section at the top.  
   For each environment you define, a new hostname will be created as [team_environments].[team_name].[top_level_domain_name]

1. For conveniency, export the `team_name` you just set:

    ```
    export TEAM_NAME=[your team name as defined in the `terraform.tfvars` file]
    ```

## Provision DNS Zone and EIP

1. Create the S3 bucket to hold the Terraform state file

    ```
    cd terraform_dns
    ./tools/create-dns-s3-state-bucket \
        -d build.gds-reliability.engineering \
        -p re-build-systems \
        -t $TEAM_NAME
    ```

1. Export secrets

    In order to initialise with Terraform the S3 bucket we have created, we need to export some secrets from the `~/.aws/credentials` file.

    ```
    export AWS_ACCESS_KEY_ID="[aws key]"
    export AWS_SECRET_ACCESS_KEY="[aws secret]"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

    If you are using bash, then adding a space at the start of the `export AWS_ACCESS_KEY_ID` and `export AWS_SECRET_ACCESS_KEY` commands in the above should prevent them from being added to `~/.bash_history`.


1. Provision the DNS
    
    ```        
    terraform init \
        -backend-config="region=$AWS_DEFAULT_REGION" \
        -backend-config="bucket=tfstate-dns-$TEAM_NAME.build.gds-reliability.engineering" \
        -backend-config="key=$TEAM_NAME.build.gds-reliability.engineering.tfstate"
    ```

    ```
    terraform apply -var-file=./terraform.tfvars
    ```

## Contributing

    Refer to our [Contributing guide](CONTRIBUTING.md).

## Licence

[MIT License](LICENCE)
