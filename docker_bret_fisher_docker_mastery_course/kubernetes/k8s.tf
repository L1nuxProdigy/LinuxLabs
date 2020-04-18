##################################################################################
# VARIABLES
##################################################################################

### AMI Vars ###
variable "ubuntu_image_18-04" {default = "ami-0b418580298265d5c"}

### VPC Vars ###
variable "vpc_id_string" {default = ""}
variable "subnet_id_string" {default = ""}

### Machine Vars ###
variable "aws_keypair_name" {default = ""}
variable "t2_small_machine_type" {default = "t2.small"}
variable "t2_medium_machine_type" {default = "t2.medium"}

### Machines Configurations Scripts ###
variable "MicroK8s" {}

### Miscellaneous ###
variable "lab_name_tag" {default = "K8s Lab"}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region     = "eu-central-1"
}

##################################################################################
# VPC Resources
##################################################################################
data "aws_subnet" "subnet_id_data" {
	id = var.subnet_id_string
}

resource "aws_security_group" "SecurityGroup_main" {
	name        = var.lab_name_tag
	description = var.lab_name_tag
	vpc_id      = var.vpc_id_string

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "TCP"
		cidr_blocks = ["0.0.0.0/0"]
		description = "SSH"
	}
	ingress {
		from_port   = 0
		to_port     = 0
		protocol    = "-1"
		cidr_blocks = [data.aws_subnet.subnet_id_data.cidr_block]
		description = "Lab all to all Communication"
	}
	  
	egress {
		from_port       = 0
		to_port         = 0
		protocol        = "-1"
		cidr_blocks     = ["0.0.0.0/0"] 
	}
	
	tags = {
	Purpose = var.lab_name_tag
	DeployedBy = "Terraform"
	}
}

##################################################################################
# EC2 Resources
##################################################################################

resource "aws_instance" "MicroK8s" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id_string
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]

	tags = {
	Name = "MicroK8s"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = var.lab_name_tag
	}
	
	user_data = file(var.MicroK8s)
}

##################################################################################
# OUTPUT
##################################################################################

output "MicroK8s" {
	value = ["${aws_instance.MicroK8s.public_ip}"]
}