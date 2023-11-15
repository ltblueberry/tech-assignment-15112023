# tech-assignment-15112023
Tech assignment description and requirements were recieved by email.

## Requirements
- **aws** (>=aws-cli/2.13.35) - AWS CLI tool for interaction with AWS. [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **terraform** (>=v1.6.3 on darwin_amd64) - CLI tool for IaC provisioning of AWS. [Installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Configure CLI
All CLI should be configured first
- [Configure the AWS CLI with credentials](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html)
- [Configure the AWS Provider for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

For this technical assignment I have a simple configuration
```
# ~/.aws/credentials
[default]
aws_access_key_id = XXXXXXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# ~/.aws/config 
[default]
region = eu-central-1
output = json
```