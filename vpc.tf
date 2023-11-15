data "aws_availability_zones" "eu_cen_1" {
  state = "available"
}

# VPC for development environment
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "develop-vpc"
  cidr = "10.42.0.0/16"

  azs             = data.aws_availability_zones.eu_cen_1.zone_ids
  private_subnets = ["10.42.1.0/24", "10.42.2.0/24", "10.42.3.0/24"]
  public_subnets  = ["10.42.101.0/24", "10.42.102.0/24", "10.42.103.0/24"]

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false
  create_igw             = true

  enable_dns_hostnames         = true
  enable_dns_support           = true
  
  create_database_subnet_group = false

  tags = {
    Environment = "develop"
    Terraform = "true"
  }
}