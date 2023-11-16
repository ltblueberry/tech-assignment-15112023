locals {
  user_data = <<-EOF
              #!/bin/bash
              wget https://github.com/ltblueberry/tech-assignment-demo-app/releases/download/v1.0.0/v1.0.0.zip
              unzip v1.0.0.zip
              python3 -m ensurepip --upgrade
              pip3 install -r requirements.txt
              nohup python3 application.py > log.txt 2>&1 &
              EOF
}



module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "7.2.0"

  name = "app-autoscaling-group"

  vpc_zone_identifier = module.vpc.private_subnets
  min_size            = 1
  max_size            = 5
  desired_capacity    = 3

  image_id      = "ami-0a485299eeb98b979" # Amazon Linux ami-0a485299eeb98b979 (64-bit (x86)) / ami-0ca82fa36091d6ada (64-bit (Arm))
  instance_type = "t2.micro"

  target_group_arns = [module.alb.target_groups.instance.arn]
  user_data = base64encode(local.user_data)

  network_interfaces = [
    {
      delete_on_termination       = true
      associate_public_ip_address = false
      description                 = "eth0"
      device_index                = 0
      security_groups             = [module.sg.security_group_id]
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "develop"
  }

  depends_on = [module.vpc]
}
