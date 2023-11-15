# Template of EC2 instances for AutoScaling group
resource "aws_launch_template" "app_instance" {
  name = "app-instance"

  image_id      = "ami-0a485299eeb98b979" # Amazon Linux ami-0a485299eeb98b979 (64-bit (x86)) / ami-0ca82fa36091d6ada (64-bit (Arm))
  instance_type = "t2.micro"
  
  # Will be deployed to private subnets after debug
  # network_interfaces {
  #   associate_public_ip_address = false
  #   subnet_id     = module.vpc.private_subnets[0]
  # }
  
  security_group_names = [module.sg.security_group_name]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              wget https://github.com/ltblueberry/tech-assignment-demo-app/releases/download/v1.0.0/v1.0.0.zip
              unzip v1.0.0.zip
              python3 -m ensurepip --upgrade
              pip3 install -r requirements.txt
              nohup python3 application.py > log.txt 2>&1 &
              EOF
  
  tags = {
    Terraform   = "true"
    Environment = "develop"
  }

  ## FOR DEBUG, first deploy to public subnet, will be removed
  key_name = "debug-rsa"
  network_interfaces {
    associate_public_ip_address = true
    subnet_id = module.vpc.public_subnets[0]
  }
}