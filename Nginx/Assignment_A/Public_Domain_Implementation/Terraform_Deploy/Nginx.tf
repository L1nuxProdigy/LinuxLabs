##################################################################################
# VARIABLES
##################################################################################

### Connection Vars ###
variable "aws_access_key" {
    default = "<your_aws_access_key>"
}
variable "aws_secret_key" {
    default = "<your_aws_secret_key>"
}
variable "aws_key_name" {
    default = "<your_aws_key_name>"
}

### Machines Configurations Scripts ###
variable "user_data_dummy_exporter_path1" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

##################################################################################
# VPC Resources
##################################################################################
resource "aws_vpc" "VPC_main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = "TRUE"
  tags = {
	Name = "Terraform_VPC"
  }
}

resource "aws_subnet" "Subnet_main" {
  vpc_id     = "${aws_vpc.VPC_main.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "TRUE"

  tags = {
	Name = "Terraform_Subnet"
  }
}

resource "aws_internet_gateway" "IG_main" {
  vpc_id = "${aws_vpc.VPC_main.id}"

  tags = {
    Name = "Terraform_IG"
  }
}

resource "aws_route_table" "Route_Table_main" {
  vpc_id = "${aws_vpc.VPC_main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.IG_main.id}"
  }

  tags = {
    Name = "Terraform_Route"
  }
}

resource "aws_main_route_table_association" "VPC_Route_Association" {
  vpc_id         = "${aws_vpc.VPC_main.id}"
  route_table_id = "${aws_route_table.Route_Table_main.id}"
}

resource "aws_route_table_association" "VPC_Subnet_Association" {
  subnet_id      = "${aws_subnet.Subnet_main.id}"
  route_table_id = "${aws_route_table.Route_Table_main.id}"
}

	
resource "aws_security_group" "SecurityGroup_main" {
	name        = "Terraform_SG"
	description = "Terraform_SG_Configuration_For_Nginx"
	vpc_id      = "${aws_vpc.VPC_main.id}"

	ingress {
		from_port   = 22
		to_port     = 22
		protocol    = "TCP"
		cidr_blocks = ["0.0.0.0/0"]
		description = "SSH"
      }
	ingress {
		from_port   = 80
		to_port     = 80
		protocol    = "TCP"
		cidr_blocks = ["0.0.0.0/0"]
		description = "HTTP"
      }
	ingress {
		from_port   = 443
		to_port     = 443
		protocol    = "TCP"
		cidr_blocks = ["0.0.0.0/0"]
		description = "HTTPS"
      }
	  
	egress {
		from_port       = 0
		to_port         = 0
		protocol        = "-1"
		cidr_blocks     = ["0.0.0.0/0"]
        
	}
	
	tags = {
    Name = "Terraform_SG"
  }
}

##################################################################################
# EC2 Resources
##################################################################################

resource "aws_instance" "Facing_NginX_Reverse_Proxy" {
	ami           = "ami-0ac019f4fcb7cb7e6"
	instance_type = "t2.micro"
	key_name        = "${var.aws_key_name}"
	subnet_id = "${aws_subnet.Subnet_main.id}"
	vpc_security_group_ids = ["${aws_security_group.SecurityGroup_main.id}"]
	iam_instance_profile = "${aws_iam_instance_profile.Consul_IAM_Profile.name}"
	
	tags = {
	Name = "Nginx_Reverse_Proxy_By_Terraform"
	}
	
	user_data = "${file(var.user_data_dummy_exporter_path1)}"
}

resource "aws_instance" "App_with_Consul_client-2" {
	ami           = "ami-0ac019f4fcb7cb7e6"
	instance_type = "t2.micro"
	key_name        = "${var.aws_key_name}"
	subnet_id = "${aws_subnet.Subnet_main.id}"
	vpc_security_group_ids = ["${aws_security_group.SecurityGroup_main.id}"]
	iam_instance_profile = "${aws_iam_instance_profile.Consul_IAM_Profile.name}"
	
	tags = {
	Name = "APP2_by_Terraform"
	}
	
	user_data = "${file(var.user_data_dummy_exporter_path2)}"
}

##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
	value = "${aws_instance.App_with_Consul_client-1.public_dns}"
}