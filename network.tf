provider "aws" {
  region = "us-east-1"  # Specify your desired AWS region
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"  # Specify the desired availability zone-1
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"  # Specify the desired availability zone-2
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-2"
  }
}
# Create private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"  # Specify the desired availability zone

  tags = {
    Name = "PrivateSubnet"
  }
}
# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}
# Create a public route table
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PublicSubnetRouteTable"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

# Create a route for the public subnet
resource "aws_route" "route_to_internet" {
  route_table_id         = aws_route_table.public_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
}

# Create NAT Gateway in the public subnet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

# Create a private route table
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PrivateSubnetRouteTable"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

# Create a route for the private subnet through the NAT Gateway
resource "aws_route" "route_to_nat_gateway" {
  route_table_id         = aws_route_table.private_subnet_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}




