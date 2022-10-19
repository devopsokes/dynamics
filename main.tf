terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.15.1"
    }
  }
}
provider "aws" {
  region  = var.region
  profile = var.profile
}
# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = var.my-vpc_cidr
  tags = {
    Name = "Demo VPC"
  }
}
locals {
  ami           = var.ami
  instance_type = var.instance_type
  my-vpc_cidr   = var.my-vpc_cidr
}
resource "aws_instance" "my_server" {
  ami           = local.ami
  instance_type = local.instance_type
}
locals {
  ingress_rules = [{
    port        = 443
    description = "port 443"
    protocol    = "tcp"
    },
    {
      port = 22
      description = "port 22"
      protocol = "tcp"

    },
    {
      port        = 80
      description = "port 80"
      protocol    = "tcp"
  }
  
  ]
}

resource "aws_security_group" "Apache" {
  name        = "apache_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol = ingress.value.protocol
    }
  }
}
output "my_security_group" {
  value = "aws_security_group.Apache1"
  
}
