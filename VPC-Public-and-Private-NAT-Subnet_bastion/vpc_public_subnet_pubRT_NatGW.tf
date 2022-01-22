resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_name}_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
   vpc_id = aws_vpc.my_vpc.id
   cidr_block = var.public_subnet_cidr
   availability_zone = var.avail_zone
   map_public_ip_on_launch = true
   tags = {
     Name = "${var.env_name}-public"
   }
}

resource "aws_internet_gateway" "gw" {
   vpc_id = aws_vpc.my_vpc.id
   tags = {
     Name = "${var.env_name}-GW"
   }
}

resource "aws_eip" "nat-ip" {
   vpc=true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat-ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.env_name}-NAT-GW"
  }
}

resource "aws_route_table" "public_RT" {
   vpc_id = aws_vpc.my_vpc.id
   route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id  
   }
   tags = {
     Name = "${var.env_name}-public-RT"
   }
}

resource "aws_route_table_association" "public_ass" {
   subnet_id = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.public_RT.id
}