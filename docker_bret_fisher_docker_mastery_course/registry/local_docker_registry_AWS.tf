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
variable "docker_client" {}
variable "docker_registry" {}

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
	name        = "Registry Lab Security Group"
	description = "Registry Lab Security Group"
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
		description = "Registry all to all Communication"
	}
	  
	egress {
		from_port       = 0
		to_port         = 0
		protocol        = "-1"
		cidr_blocks     = ["0.0.0.0/0"] 
	}
	
	tags = {
	Purpose = "Docker Registry Lab"
	DeployedBy = "Terraform"
	}
}

##################################################################################
# Route 53 - Internal
##################################################################################

resource "aws_route53_zone" "container" {
  name = "container"
  comment = "Deployed By Terraform - Registry Lab"

  vpc {
    vpc_id = var.vpc_id_string
  }
}


resource "aws_route53_record" "docker_client" {
  allow_overwrite = true
  name            = "client"
  ttl             = 30
  type            = "A"
  zone_id         = aws_route53_zone.container.zone_id
  records         = [aws_instance.docker_client.private_ip]
}

resource "aws_route53_record" "docker_registry" {
  allow_overwrite = true
  name            = "registry"
  ttl             = 30
  type            = "A"
  zone_id         = aws_route53_zone.container.zone_id
  records         = [aws_instance.docker_registry.private_ip]
}

##################################################################################
# EC2 Resources
##################################################################################

resource "aws_instance" "docker_client" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id_string
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]

	tags = {
	Name = "docker_client"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = "Docker Registry Lab"
	}
	
	user_data = file(var.docker_client)
}

resource "aws_instance" "docker_registry" {
	ami                    = var.ubuntu_image_18-04
	instance_type          = var.t2_medium_machine_type
	key_name               = var.aws_keypair_name
	subnet_id              = var.subnet_id_string
	vpc_security_group_ids = [aws_security_group.SecurityGroup_main.id]
	
	tags = {
	Name = "docker_registry"
	DeployedBy = "Terraform"
	OS = "Ubuntu 18.04"
	Purpose = "Docker Registry Lab"
	}
	
	user_data = file(var.docker_registry)
}

##################################################################################
# OUTPUT
##################################################################################

output "docker_client" {
	value = ["${aws_instance.docker_client.public_ip}"]
}

output "docker_registry" {
	value = ["${aws_instance.docker_registry.public_ip}"]
}