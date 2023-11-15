# EC2 instance with demo application
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0"

  name = "app-instance"

  ami           = "ami-0a485299eeb98b979" # Amazon Linux ami-0a485299eeb98b979 (64-bit (x86)) / ami-0ca82fa36091d6ada (64-bit (Arm))
  instance_type = "t2.micro"
  # subnet_id     = module.vpc.private_subnets[0] # Will be deployed to private subnets after debug
  
  vpc_security_group_ids = [module.sg.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  user_data = <<-EOF
              #!/bin/bash
              wget https://github.com/ltblueberry/tech-assignment-demo-app/releases/download/v1.0.0/v1.0.0.zip
              unzip v1.0.0.zip
              python3 -m ensurepip --upgrade
              pip3 install -r requirements.txt
              python3 application.py
              EOF
  
  tags = {
    Terraform   = "true"
    Environment = "develop"
  }

  ## FOR DEBUG, first deploy to public subnet, will be removed
  key_name = "debug-rsa"
  associate_public_ip_address = true
  subnet_id     = module.vpc.public_subnets[0]
}