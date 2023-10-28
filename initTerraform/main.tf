# configure aws provider
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = "us-east-1"
#    profile = "Admin"
}

##################################VPCS###################################

# Create VPC make sure to include a cidr range 
resource "aws_vpc" "dep6_vpc_east" {
 cidr_block = "10.0.0.0/16"

 tags = {
   Name = "Deployment6VPC_East"
 }
}

##################################EAST-SUBNETS####################################

# Creating Public Subnet 1 (us-east-1a)
resource "aws_subnet" "public_subneta_e" {
 vpc_id     = aws_vpc.dep6_vpc_east.id
 availability_zone = "us-east-1a"
 cidr_block = "10.0.2.0/24"
 map_public_ip_on_launch = true 
 tags = {
   Name = "D6PublicSubnet_EA"
 }
}

# Creating Public Subnet 2 (us-east-1b)
resource "aws_subnet" "public_subnetb_e" {
 vpc_id     = aws_vpc.dep6_vpc_east.id
 availability_zone = "us-east-1b"
 cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true 
 tags = {
   Name = "D6PublicSubnet_EB"
 }
}


##################################INTERNET-GATEWAY####################################

# Making an Internet Gateway for EAST VPC
resource "aws_internet_gateway" "igw_e" {
 vpc_id = aws_vpc.dep6_vpc_east.id
 
 tags = {
   Name = "dep6_east_IG"
 }
}


##################################SECURITY-GROUPS####################################


# Creating Security Group for EAST VPC to include ports 22, 8080, 8000 of ingress 
 resource "aws_security_group" "dep6_east_sg" {
 name = "deployment6_East_SG"
 vpc_id = aws_vpc.dep6_vpc_east.id

 ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

 }

 ingress {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
 }

 ingress {
  from_port = 8000
  to_port = 8000
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
 }

 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }
 
 tags = {
  "Name" : "deployment6_East_SG"
  "Terraform" : "true"
 }

}


##################################ROUTE-TABLES####################################


#associating the default route table that Terraform will create with the East internet gateway and everything that exists within the East vpc 
resource "aws_default_route_table" "deproute6_east" {
  default_route_table_id = aws_vpc.dep6_vpc_east.default_route_table_id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_e.id
  }
}


##################################EAST-INSTANCES####################################


# Create Instance 1 (Webserver1)
resource "aws_instance" "instance1" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "Deployment6-EAST"
  subnet_id              = aws_subnet.public_subneta_e.id
  vpc_security_group_ids = [aws_security_group.dep6_east_sg.id]
  user_data              = "${file("setup.sh")}"
  
  tags = {
    "Name" : "D6_Application1_EAST"
  }
}

# Create Instance 2 (Application1)
resource "aws_instance" "instance2" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = "Deployment6-EAST"
  subnet_id              = aws_subnet.public_subnetb_e.id
  vpc_security_group_ids = [aws_security_group.dep6_east_sg.id]
  user_data              = "${file("setup.sh")}"
  
  tags = {
    "Name" : "D6_Application2_EAST"
  }
}


