# Configure the AWS Provider
provider "aws" {
	access_key = var.access
	secret_key = var.secret
    region = var.region
}

# Create Subnet Private
resource "aws_subnet" "private-SUBNET" {
  vpc_id            = aws_vpc.my-VPC.id
  cidr_block        = "10.0.1.128/25"


  tags = {
    Name = "private-SUBNET"
  }
}

# Create Windows Server
resource "aws_instance" "Windows-Server" {
  ami           = "ami-00f0f1e05a950042b"
  instance_type = var.instance_type
  subnet_id   = aws_subnet.public-SUBNET.id
  key_name = "aws-philipsn"
  #vpc_security_group_ids = [aws_security_group.Management-SG.id]
  security_groups = [aws_security_group.Management-SG.id]
  user_data = file("script.sh")
    tags = {
    Name = "Windows-Server"
    Owner = "Andrei Rudnikov"
    Project = "Final Project"
    }
  }

resource "aws_key_pair" "pxilips" {
  key_name   = "aws-philipsn"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDwskRn1zpmbl47FSe+VfSDO/XBEb7dro1soGs7JLAz5Dk8Od4cc4Cxi0HdutItTisOTgGw8I4OMXQ9FBaLh9vYLzV9KZ0zZMmnK0FysOh3fUenVtYqdYXORfBxkpQ3vBTnAQH1n1kFXj1uyqVlnZK1ycRf4kjcwKJbcDkjWO4jLOOFlmJzxKMNdkzS3FUrWmXDCMjuc4jSYyTIfKlew3pR7OMMH9ZmzQ7h60n9rc26uoLS4HlLrHsJHzuWCpLab+zT8T1nVHVnf4V2WotmrSq8hePW19H+NbDGxoxhCj30wS46Z2n8h95+I0SUcyN6a1/zoDiOwkWuea6RVBBkZfiL imported-openssh-key"
}

#Private NAT
resource "aws_nat_gateway" "private-NAT" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private-SUBNET.id
}

## Create Route Table Privat
resource "aws_route_table" "my-VPC-RT-private" {
  vpc_id = aws_vpc.my-VPC.id
  
route {
    cidr_block = "10.0.1.0/25"
    nat_gateway_id = aws_nat_gateway.private-NAT.id
  }
  
    tags = {
    Name = "my-VPC-RT-private"
  }
}

resource "aws_route_table_association" "my-VPC-RT-private" {
  subnet_id   = aws_subnet.private-SUBNET.id
  route_table_id = aws_route_table.my-VPC-RT-private.id
}