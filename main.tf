# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr_block
  availability_zone = var.availability_zone
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table for the Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "my_eip" {}

# Create a route table for the Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }
}

# Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


# Create a security group for the instance
resource "aws_security_group" "instance_security_group" {
  name_prefix = "instance_sg_"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AWS_KEY_PAIR_NAME
resource "aws_key_pair" "vishal_key" {
  key_name   = "aws-key"
  public_key = file("${path.module}/mykey.pub")
}

# Create an EC2 instance in the Private Subnet
resource "aws_instance" "private_instance" {
  ami           = var.instance_ami
  key_name      = "aws-key"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [
    aws_security_group.instance_security_group.id,
  ]
}

# Check internet access from the instance
resource "null_resource" "check_internet_access" {
  depends_on = [
    aws_nat_gateway.my_nat_gateway,
    aws_instance.private_instance,
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./mykey")
    host        = aws_eip.my_eip.public_ip
  }

}

