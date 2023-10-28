# configure aws provider
provider "aws" {
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
    region = "us-west-1"
#    profile = "Admin"
}

##################################VPCS###################################

# Create VPC make sure to include a cidr range 
resource "aws_vpc" "dep6_vpc_west" {
 cidr_block = "10.0.0.0/16"
 tags = {
   Name = "Deployment6VPC_West"
 }
}

##################################WEST-SUBNETS####################################

# Creating Public Subnet 3 (us-west-1a)
resource "aws_subnet" "public_subneta_w" {
 vpc_id     = aws_vpc.dep6_vpc_west.id
 availability_zone = "us-west-1a"
 cidr_block = "10.0.2.0/24"
 map_public_ip_on_launch = true 

 tags = {
   Name = "D6PublicSubnet_WA"
 }
}

# Creating Public Subnet 4 (us-west-1b)
resource "aws_subnet" "public_subnetb_w" {
 vpc_id     = aws_vpc.dep6_vpc_west.id
 availability_zone = "us-west-1b"
 cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true 

 tags = {
   Name = "D6PublicSubnet_WB"
 }
}

##################################INTERNET-GATEWAY####################################

# Making an Internet Gateway for WEST VPC 
resource "aws_internet_gateway" "igw_w" {
 vpc_id = aws_vpc.dep6_vpc_west.id
 
 tags = {
   Name = "dep6_eest_IG"
 }
}

##################################SECURITY-GROUPS####################################

# Creating Security Group for WEST VPC to include ports 22, 8080, 8000 of ingress 
 resource "aws_security_group" "dep6_west_sg" {
 name = "deployment6_West_SG"
 vpc_id = aws_vpc.dep6_vpc_west.id

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
  "Name" : "deployment6_West_SG"
  "Terraform" : "true"
 }

}


##################################ROUTE-TABLES####################################


#associating the default route table that Terraform will create with the East internet gateway and everything that exists within the East vpc 
resource "aws_default_route_table" "deproute6_west" {
  default_route_table_id = aws_vpc.dep6_vpc_west.default_route_table_id
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_w.id
  }
}

##################################WEST-INSTANCES###################################

# Create Instance 3 (Webserver2)
resource "aws_instance" "instance3" {
  ami                    = "ami-0cbd40f694b804622"
  instance_type          = "t2.micro"
  key_name               = "Deployment6-WEST"
  subnet_id              = aws_subnet.public_subneta_w.id
  vpc_security_group_ids = [aws_security_group.dep6_west_sg.id]
  user_data              = "${file("setup.sh")}"
  
  tags = {
    "Name" : "D6_Application3_WEST"
  }
}

# Create Instance 4 (Application2)
resource "aws_instance" "instance4" {
  ami                    = "ami-0cbd40f694b804622"
  instance_type          = "t2.micro"
  key_name               = "Deployment6-WEST"
  subnet_id              = aws_subnet.public_subnetb_w.id
  vpc_security_group_ids = [aws_security_group.dep6_west_sg.id]
  user_data              = "${file("setup.sh")}"
  
  tags = {
    "Name" : "D6_Application4_WEST"
  }
}
