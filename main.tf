terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
 
provider "aws" {

  region  = "eu-west-2"
}
 
data "aws_ami" "ubuntu" {
    most_recent = true
 
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
 
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
 
    filter {
        name   = "architecture"
        values = ["x86_64"]
    }
 
    owners = ["099720109477"] # Canonical official
}
 
variable infra_env {
    type = string
    description = "infrastructure environment"
}
 
variable default_region {
    type = string
    description = "the region this infrastructure is in"
    default = "us-east-2"
}
 
variable instance_size {
    type = string
    description = "ec2 web server size"
    default = "t3.small"
}
 
 
module "ec2_app" {
   source = "git::git@github.com:lalits77/terraform-module-1.git"
 
   infra_env = var.infra_env
   infra_role = "app"
   instance_size = "t3.small"
   instance_ami = data.aws_ami.app.id
   # instance_root_device_size = 12 # Optional
}
 
module "ec2_worker" {
   source = "git::git@github.com:lalits77/terraform-module-1.git"
 
   infra_env = var.infra_env
   infra_role = "worker"
   instance_size = "t3.large"
   instance_ami = data.aws_ami.app.id
   instance_root_device_size = 50
}

module "ec2_master" {
   source = "git::git@github.com:lalits77/terraform-module-2.git"
 
   infra_env = var.infra_env
   infra_role = "worker"
   instance_size = "t3.large"
   instance_ami = data.aws_ami.app.id
   instance_root_device_size = 50
}