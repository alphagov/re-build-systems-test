# Reliability Engineering - Build Systems - Customer DNS and EIP Configuration

It will configure a customers subdomain and eip, which will allow them to remain persistent as they will be maintained within their own state file.


## Contributing

Refer to our [Contributing guide](CONTRIBUTING.md).

## Prerequisites

    * Install Terraform v0.11.7 (see https://www.terraform.io/intro/getting-started/install.html for guidance for your system)

    * Install Python3
      On a Mac, you can use
      `brew install awscli python3`

      On a Linux machine, you can use
      `apt-get install python3`

## Configuration

1. Configure your ~/.aws/credentials file with your own details:

    ```
    [re-build-systems]
    aws_access_key_id = AABBCCDDEEFFG
    aws_secret_access_key = abcdefghijklmnopqrstuvwxyz1234567890
    ```

2. Configure your DNS zone
		Edit terraform_dns/terraform.tfvars with your required configuration


## Provision DNS Zone
1. Export secrets

    In order to initialise with Terraform the S3 bucket we have created, we need to export some secrets from the `~/.aws/credentials` file.

    ```
    export AWS_ACCESS_KEY_ID="AABBCCDDEEFFG"
    export AWS_SECRET_ACCESS_KEY="abcdefghijklmnopqrstuvwxyz1234567890"
    export AWS_DEFAULT_REGION="eu-west-2"
    ```

2. Run Terraform

    ```
    cd terraform_dns
    ./tools/create-dns-s3-state-bucket -d build.gds-reliability.engineering -p re-build-systems -t [your team name]
    terraform init -backend-config="region=eu-west-2" -backend-config="bucket=tfstate-dns-[your team name].build.gds-reliability.engineering" -backend-config="key=zone-team1.build.gds-reliability.engineering.tfstate"
    ```

## Licence

[MIT License](LICENCE)
