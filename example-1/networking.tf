# Create a VPC
resource "aws_vpc" "ex1" {
  cidr_block = "10.3.14.0/24"

	tags = {
    Name = "ex1"
  }

}

resource "aws_subnet" "pub1" {
  vpc_id     = aws_vpc.ex1.id
  cidr_block = var.public_subnet
	availability_zone = "eu-west-1a"
  tags = {
    Name = "pub1"
  }
}

resource "aws_subnet" "priv1" {
  vpc_id     = aws_vpc.ex1.id
  cidr_block = var.private_subnet
	availability_zone = "eu-west-1a"
	
  tags = {
    Name = "priv1"
  }
}


resource "aws_internet_gateway" "ex1" {
  vpc_id = aws_vpc.ex1.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.ex1 ]
}

resource "aws_nat_gateway" "ex1" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # depends_on = [aws_internet_gateway.ex1]
}

resource "aws_route_table" "pub_ex1" {
  vpc_id = aws_vpc.ex1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ex1.id
  }

  tags = {
    Name = "public_ex1_rt"
  }
}

resource "aws_route_table" "priv_ex1" {
  vpc_id = aws_vpc.ex1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ex1.id
  }

  tags = {
    Name = "private_ex1_rt"
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub_ex1.id
}

resource "aws_route_table_association" "priv" {
  subnet_id      = aws_subnet.priv1.id
  route_table_id = aws_route_table.priv_ex1.id
}


resource "aws_security_group" "secgrp_pub" {

  name        = "ex1-secgrp-pub"
  description = "Allow SSH"
  vpc_id      = aws_vpc.ex1.id

  ingress {

    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ex1.cidr_block]

  }
}

resource "aws_security_group" "secgrp_priv" {

  name        = "ex1-secgrp-priv"
  description = "Allow SSH"
  vpc_id      = aws_vpc.ex1.id

  ingress {

    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.ex1.cidr_block]
  }

  egress { # allow egress to all

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
