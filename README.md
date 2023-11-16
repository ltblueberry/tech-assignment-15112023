# tech-assignment-15112023
Tech assignment description and requirements were received by email.

## Requirements
- **aws** (>=aws-cli/2.13.35) - AWS CLI tool for interaction with AWS. [Installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **terraform** (>=v1.6.3 on darwin_amd64) - CLI tool for IaC provisioning of AWS. [Installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Configure CLI
All CLI should be configured first
- [Configure the AWS CLI with credentials](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-configure.html)
- [Configure the AWS Provider for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

For this technical assignment I have a simple AWS CLI configuration
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

Terraform AWS Provider will be using AWS CLI configuration
```
The AWS Provider can source credentials and other settings from the shared configuration and credentials files. By default, these files are located at $HOME/.aws/config and $HOME/.aws/credentials on Linux and macOS
```

For this technical assignment I have local backend for Terraform State.
I think it is OK in that case, but in real situation it is better to do another approach (S3 for example) to store state files 🙂

## Application
The application from this git repository [ltblueberry/tech-assignment-demo-app](https://github.com/ltblueberry/tech-assignment-demo-app) will be used as a demo application for this technical assignment.
The application listens to `:5000` port with `/` endpoint and returns name of the host where it is running.

## Structure
- [**provider.tf**](./provider.tf) - the configuration of terraform provider
- [**variables.tf**](./variables.tf) - the declaration of input variables for technical assignment
- [**technical-assignment.terraform.tfvars**](./technical-assignment.terraform.tfvars) - variables files with input values for technical assignment
- [**output.tf**](./output.tf) - the declaration of output variables to get details about created resources
- [**vpc.tf**](./vpc.tf) - the deployment of the VPC and network resources. The terraform module [terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) is used.
- [**security-group.tf**](./security-group.tf) - the deployment of the Security Group. The terraform module [terraform-aws-security-group](https://github.com/terraform-aws-modules/terraform-aws-security-group) is used.
- [**load-balancer.tf**](./load-balancer.tf) - the deployment of the Application Load Balancer. The terraform module [terraform-aws-alb](https://github.com/terraform-aws-modules/terraform-aws-alb) is used.
- [**autoscaling-group.tf**](./autoscaling-group.tf) - the deployment of the Auto Scaling Group. The terraform module [terraform-aws-autoscaling](https://github.com/terraform-aws-modules/terraform-aws-autoscaling) is used. 
- [**check.sh**](./check.sh) - a bash script with the simple check.

## Initialization
Initialize new Terraform configuration, install provider and modules, setup backend for storing Terraform State.
```
terraform init
```

## Plan 
Before applying changes check execution plan, what is the difference between the desired state and the current state.
```
terraform plan -var-file=technical-assignment.terraform.tfvars
```

It should be `43` resources `to add` for the fresh start.

Expected output
```
...
Plan: 43 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + load_balancer_dns_name = (known after apply)
```

## Deployment
Apply the changes required to reach the desired state of the Terraform configuration
```
terraform apply -var-file=technical-assignment.terraform.tfvars
```

Expected output like this
```
...
module.autoscaling.aws_autoscaling_group.this[0]: Creation complete after 47s [id=app-autoscaling-group-xxxxxxxxxxxxxxxxxxxxxxxxxx]
module.autoscaling.aws_autoscaling_policy.this["policyCPU60"]: Creating...
module.autoscaling.aws_autoscaling_policy.this["policyCPU60"]: Creation complete after 0s [id=policyCPU60]
module.alb.aws_lb.this[0]: Still creating... [2m50s elapsed]
module.alb.aws_lb.this[0]: Creation complete after 2m52s [id=arn:aws:elasticloadbalancing:eu-central-1:xxxxxxxxxxxx:loadbalancer/app/develop-alb/xxxxxxxxxxxxxxxx]
module.alb.aws_lb_listener.this["http"]: Creating...
module.alb.aws_lb_listener.this["http"]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:xxxxxxxxxxxx:listener/app/develop-alb/xxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxx]

Apply complete! Resources: 43 added, 0 changed, 0 destroyed.

Outputs:

load_balancer_dns_name = "develop-alb-xxxxxxxxxx.eu-central-1.elb.amazonaws.com"
```

## Check
Application Load Balancer DNS name will be stored in output variables.
```
terraform output
```

Copy Load Balancer DNS name and pass it to the check script.
```
./check.sh <DNS_NAME>

#example
./check.sh ./check.sh develop-alb-xxxxxxxxx.eu-central-1.elb.amazonaws.com
```

Expected output like this
```
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
ip-10-42-1-x.eu-central-1.compute.internal
ip-10-42-2-x.eu-central-1.compute.internal
ip-10-42-3-x.eu-central-1.compute.internal
```

## Summarize
From the result of the check script output you can see next things:
- When accessing the DNS name of the Load Balancer, it redirects to different virtual machines from the autoscaling group. You may see different hostnames in HTTP response.
- All virtual machines are hosted in private subnets. IP addresses that are part of hostnames are related to [private subnets CIDR](https://github.com/ltblueberry/tech-assignment-15112023/blob/main/vpc.tf#L14).

## Cleanup
Clean up created resources when everything is done and checked 🙂
```
terraform destroy -var-file=technical-assignment.terraform.tfvars
```

## Example
Please find this walkthrough [example](https://github.com/ltblueberry/tech-assignment-15112023/tree/main/example) related to this technical assignment in case you have questions or troubles.

<br>

---
It was nice and fun 😊

Best regards