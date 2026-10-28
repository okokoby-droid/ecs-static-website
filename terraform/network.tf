
# Create a Virtual Private Cloud
resource "aws_vpc" "website" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ecs-website-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.website.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ecs-website-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "website" {
  vpc_id = aws_vpc.website.id

  tags = {
    Name = "ecs-website-igw"
  }
}

# Create a public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.website.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.website.id
  }

  tags = {
    Name = "ecs-website-public-route-table"
  }
}

# Associate the subnet with the route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Allow HTTP access to the website
resource "aws_security_group" "website" {
  name        = "ecs-website-sg"
  description = "Allow HTTP traffic to ECS website"
  vpc_id      = aws_vpc.website.id

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-website-security-group"
  }
}

