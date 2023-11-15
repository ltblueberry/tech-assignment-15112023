# Security Group for EC2 instances
module "sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "ec2-sg"
  description = "Security group for hostname application"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["10.42.0.0/16"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Application"
      cidr_blocks = "10.42.0.0/16"
    },
    { # FOR DEBUG
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    { # FOR DEBUG
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "all for app"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port = "0"
      to_port   = "0"
      protocol  = "-1"
      description = "all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}