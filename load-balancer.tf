# Application Load Balancer
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.2.0"

  name    = "develop-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  
  # Disable deletion protection just for this demo case
  # So the cleanup process could be done without any problems
  enable_deletion_protection = false

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.42.0.0/16"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "instance"
      }
    }
  }

  target_groups = {
    instance = {
      name_prefix       = "app-"
      protocol          = "HTTP"
      protocol_version  = "HTTP1"
      port              = 5000
      target_type       = "instance"

      create_attachment = false
      # target_id        = module.ec2_instance.id
    }
  }

  tags = {
    Environment = "develop"
    Terraform   = "true"
  }
}
