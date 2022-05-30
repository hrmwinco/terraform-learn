/*
#TERRAFORM TUTORIAL - CREATING MULTIPLE INSTANCES (COUNT, LIST TYPE AND ELEMENT() FUNCTION)
https://www.bogotobogo.com/DevOps/Terraform/Terraform-creating-multiple-instances-count-list-type.php



 https://stackoverflow.com/questions/65671433/terraform-multiple-instance-types-from-count
https://stackoverflow.com/questions/65664963/ec2-instance-creation

This code uses Terraform to provision AWS and create 3 t2.micro instances. 1 redhat, 1 aws linux and 1 ubuntu
It creates a security group that allows all inbound traffic but can only ssh to instances via my IP address
*/
data aws_availability_zones "azs" {}


resource "aws_key_pair" "efsonmultios" {
  key_name   = "efsonmultios"
  public_key = file("efsonmultios.pub")
}


resource "aws_instance" "my-instance" {
  count = length(var.azcount)
  ami           = lookup(var.ami,var.aws_region)
  instance_type = var.instance_type
  key_name      = aws_key_pair.efsonmultios.key_name
  user_data     = file("multios_websetup.sh")
  security_groups             = ["${aws_security_group.efsonmultios-sg.id}"]
  subnet_id                   = aws_subnet.public-subnet[count.index].id
  associate_public_ip_address = true  

  tags = {
    Name  = element(var.instance_tags, count.index)
  }
}


# Create VPC
# terraform aws create vpc
resource "aws_vpc" "vpc" {
cidr_block = "10.0.0.0/16"
enable_dns_hostnames    = true
tags      = {
Name    = "Test_VPC"
}
}
# Create Internet Gateway and Attach it to VPC
# terraform aws create internet gateway
resource "aws_internet_gateway" "internet-gateway" {
vpc_id    = aws_vpc.vpc.id
tags = {
Name    = "internet_gateway"
}
}
# Create Public Subnet 
# terraform aws create subnet
resource "aws_subnet" "public-subnet" {
vpc_id                  = aws_vpc.vpc.id
count                   = length(data.aws_availability_zones.azs.names)
cidr_block              = element(var.subnetcidr,count.index)
availability_zone       = data.aws_availability_zones.azs.names[count.index]
map_public_ip_on_launch = true
tags      = {
Name    = "public-subnet"
}
}
# Create Route Table and Add Public Route
# terraform aws create route table
resource "aws_route_table" "public-route-table" {
vpc_id       = aws_vpc.vpc.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.internet-gateway.id
}
tags       = {
Name     = "Public Route Table"
}
}

# Associate Public Subnet 1 to "Public Route Table"
# terraform aws associate subnet with route table
  resource "aws_route_table_association" "public-subnet-route-table-association" {
  count = length(data.aws_availability_zones.azs.names)
  subnet_id           = aws_subnet.public-subnet[count.index].id
  route_table_id      = aws_route_table.public-route-table.id
}


# Create Private Subnet 1
# terraform aws create subnet

/*resource "aws_subnet" "private-subnet-1" {
vpc_id                   = aws_vpc.vpc.id
cidr_block               = "${var.Private_Subnet_1}"
availability_zone        = "eu-central-1a"
map_public_ip_on_launch  = false
tags      = {
Name    = "private-subnet-1"
}
}*/

resource "aws_security_group" "efsonmultios-sg" {
  name = "efsonmultios-sg"
  vpc_id      = aws_vpc.vpc.id


  #Incoming traffic
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ssh from my IP only
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["${chomp(data.http.myip.body)}/32"]
  }

  #Outgoing traffic
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### EFS information 

# efsname = "fs01"
# pathname = "/fs01"