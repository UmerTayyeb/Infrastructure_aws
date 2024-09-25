provider "aws" {
  region = "us-east-1" 
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id     = aws_vpc.test_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"  
  tags = {
    Name = "test-subnet"
  }
}
//for public network
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}
