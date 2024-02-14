# Create a security group for the Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "BastionSecurityGroup"
  description = "Security group for the Bastion host in the public subnet"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open SSH access to the world (for demonstration purposes, consider restricting to specific IPs)
  }
}

# Launch the Bastion host in the public subnet
resource "aws_instance" "bastion_host" {
  ami           = "ami-xxxxxxxxxxxxxxxx"  # Specify your desired AMI ID
  instance_type = "t2.micro"  # Specify your desired instance type
  key_name      = "your-key-pair"  # Specify your key pair name

  subnet_id   = aws_subnet.public_subnet_1.id
  security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "BastionHost"
  }
}

# Create a security group for the private instance
resource "aws_security_group" "private_instance_sg" {
  name        = "PrivateInstanceSecurityGroup"
  description = "Security group for the private instance in the private subnet"
  vpc_id      = aws_vpc.my_vpc.id

  # Define your inbound and outbound rules as needed for your application
  # For example, allow communication within the security group, but restrict incoming traffic
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_group_ids = [aws_security_group.private_instance_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to the internet (for demonstration purposes, consider restricting)
  }
}

# Launch the private instance in the private subnet
resource "aws_instance" "private_instance" {
  ami           = "ami-xxxxxxxxxxxxxxxx"  # Specify your desired AMI ID
  instance_type = "t2.micro"  # Specify your desired instance type
  key_name      = "your-key-pair"  # Specify your key pair name

  subnet_id          = aws_subnet.private_subnet.id
  security_group_ids = [aws_security_group.private_instance_sg.id]

  tags = {
    Name = "PrivateInstance"
  }
}
