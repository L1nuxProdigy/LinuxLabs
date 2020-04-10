##################################################################################
# VARIABLES
##################################################################################

### AMI Vars ###
variable "ubuntu_image_18-04" {default = "ami-0b418580298265d5c"}

### VPC Vars ###
variable "vpc_id" {default = ""}
variable "subnet_id" {default = ""}

### Machine Vars ###
variable "aws_keypair_name" {default = ""}
variable "t2_small_machine_type" {default = "t2.small"}
variable "t2_medium_machine_type" {default = "t2.medium"}

### Machines Configurations Scripts ###
variable "swarm_node_1" {}
variable "swarm_node_2" {}
variable "swarm_node_3" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region     = "eu-central-1"
}

##################################################################################
# VPC Resources
##################################################################################
data "aws_subnet" "subnet_id" {
	id = var.subnet_id
}

resource "aws_security_group" "SecurityGroup_main" {
	name        = "Swarm Security Group"
	description = "Swarm Security Group"
	vpc_id      = var.vpc_id

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
		cidr_blocks = [data.aws_subnet.subnet_id.cidr_block]
		description = "Swarm Communication"
	}
	  
	egress {
		from_port       = 0
		to_port         = 0
		protocol        = "-1"
		cidr_blocks     = ["0.0.0.0/0"] 
	}
	
	tags = {
	Purpose = "Docker Swarm Lab"
	DeployedBy = "Terraform"
	}
}

##################################################################################
# EC2 Resources
##################################################################################

resource "aws_instance" "swarm_node_1" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]

	tags = {
	Name = "swarm_node_1"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = "Docker Swarm Lab"
	}
	
	user_data = file(var.swarm_node_1)
}

resource "aws_instance" "swarm_node_2" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]
	
	tags = {
	Name = "swarm_node_2"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = "Docker Swarm Lab"
	}
	
	user_data = file(var.swarm_node_2)
}

resource "aws_instance" "swarm_node_3" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]
	
	tags = {
	Name = "swarm_node_3"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = "Docker Swarm Lab"
	}

	user_data = file(var.swarm_node_3)
}

##################################################################################
# OUTPUT
##################################################################################

output "swarm_node_1" {
	value = ["${aws_instance.swarm_node_1.public_ip}"]
}

output "swarm_node_2" {
	value = ["${aws_instance.swarm_node_2.public_ip}"]
}

output "swarm_node_3" {
	value = ["${aws_instance.swarm_node_3.public_ip}"]
}