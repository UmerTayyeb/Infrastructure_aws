provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "test01_vpc"
  }
}

resource "aws_subnet" "test_subnet" {
    vpc_id = aws_vpc.test_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-2a"
    depends_on = [aws_vpc.test_vpc]
    tags = {
        name = "test_subnet"
    }
}

resource "aws_internet_gateway" "test_igw" {
    vpc_id = aws_vpc.test_vpc.id
    depends_on = [aws_vpc.test_vpc]
    tags = {
        Name = "test_igw"
    }
}

resource "aws_route_table" "test_rt" {
    vpc_id = aws_vpc.test_vpc.id
    depends_on = [aws_vpc.test_vpc]
     route{
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.test_igw.id
    }
    tags = {
        Name = "test RT"
    }
}

resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rt.id
  depends_on = [aws_vpc.test_vpc]
}

resource "aws_security_group" "ssh_rule" {
  name_prefix = "allow_ssh"
  description = "Allow SSH inbound traffic"
  depends_on = [aws_vpc.test_vpc]
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "test01" {
  ami                     = "ami-01fb4de0e9f8f22a7"
  instance_type           = "t2.micro"
  subnet_id = aws_subnet.test_subnet.id
  key_name = "awsTest01"
  security_groups = [aws_security_group.ssh_rule.id]  
  depends_on = [aws_security_group.ssh_rule, aws_subnet.test_subnet, aws_vpc.test_vpc]
  associate_public_ip_address = true
  tags = {
    Name = "first instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.test01.public_ip
  description = "The public IP address of the EC2 instance"
}