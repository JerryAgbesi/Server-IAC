terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "ubuntu-image"{
    most_recent = true

    filter {
      name ="name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240701"]
    }

    owners = ["099720109477"]
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  count = 1

  name = "Terraform-demo"

  ami = data.aws_ami.ubuntu-image.id

  instance_type = "t2.micro"
  key_name = "linuxUpskill"
  user_data = file("userdata.tpl")
  vpc_security_group_ids = [aws_security_group.sg-demo.id]

  tags = {

    Terraform = "true"
    Name = "Terraform-demo"

  }

}

resource "aws_default_vpc" "default"{

}

resource "aws_security_group" "sg-demo" {
  description = "Allows ssh on port 22 and http on port 80"

  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

  
}

output "ec2_instance_public_ip" {
  description = "Public IP address of ec2 instance"
  value = module.ec2-instance[*].public_ip
}



