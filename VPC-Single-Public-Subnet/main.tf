provider "aws" {
   region = "eu-central-1"
   profile = "default"
}

resource "aws_vpc" "MyVpc" {
   cidr_block = var.vpc_cidr
   enable_dns_hostnames = true
   tags = {
     Name = "${var.env_name}_Vpc"
   }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.MyVpc.id
    cidr_block = var.public_subnet_cidr
    availability_zone = var.avail_zone
    map_public_ip_on_launch = "true"
    tags = {
      "Name" ="${var.env_name}_public_subnet"
    }
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.MyVpc.id
  tags = {
      Name= "${var.env_name}_ig"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.MyVpc.id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = {
    Name = "${var.env_name}_public_RT"
  }
}

resource "aws_route_table_association" "rt_ass" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_ssh" { 
   name        = "testSG"
   vpc_id = aws_vpc.MyVpc.id
   ingress  {
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = [ "0.0.0.0/0" ]    
   } 
   egress  {
       from_port = 0
       to_port = 0
       protocol ="-1"
       cidr_blocks = [ "0.0.0.0/0" ]
   }
   tags = {
     Name = "${var.env_name}_SG"
   }
}

resource "aws_key_pair" "test_key" {
  key_name   = "test_key"
  public_key = file(var.public_key)
}



resource "aws_instance" "my_instance" {
   ami = var.ami
   instance_type = var.instance_type
   availability_zone = var.avail_zone
   subnet_id = aws_subnet.public_subnet.id
   key_name = aws_key_pair.test_key.key_name
   vpc_security_group_ids = [aws_security_group.allow_ssh.id]
   tags = {
     Name = "${var.env_name}_EC2"
   }
}