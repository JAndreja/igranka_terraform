
resource "aws_subnet" "private_subnet" {
   vpc_id = aws_vpc.my_vpc.id
   cidr_block = var.private_subnet_cidr
   availability_zone = var.avail_zone
   tags = {
     Name = "${var.env_name}-private"
   }
}

resource "aws_route_table" "private_RT" {
   vpc_id = aws_vpc.my_vpc.id
   route  {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
   }
   tags = {
     Name = "${var.env_name}-private-RT"
   }
}

resource "aws_route_table_association" "private_ass" {
   subnet_id = aws_subnet.private_subnet.id
   route_table_id = aws_route_table.private_RT.id
}
