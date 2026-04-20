# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true # Important for EC2 accessibility

  tags = {
    Name = "${var.environment_name}-vpc"
  }
}

# 2. The Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment_name}-igw"
  }
}

# 3. A Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true # Makes this a "Public" subnet

  tags = {
    Name = "${var.environment_name}-public-subnet"
  }
}

# 4. Route Table (The Rules of the Road)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # All traffic...
    gateway_id = aws_internet_gateway.igw.id # ...goes to the Internet
  }

  tags = {
    Name = "${var.environment_name}-public-rt"
  }
}

# 5. Associate Route Table with Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}