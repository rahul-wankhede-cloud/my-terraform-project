# 1. The VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
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
/* resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true # Makes this a "Public" subnet

  tags = {
    Name = "${var.environment_name}-public-subnet"
  }
}
 */
# 4. Route Table (The Rules of the Road)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                 # All traffic...
    gateway_id = aws_internet_gateway.igw.id # ...goes to the Internet
  }

  tags = {
    Name = "${var.environment_name}-public-rt"
  }
}

/* # 5. Associate Route Table with Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}
 */
# The Subnet Loop
/* When you add for_each to a resource, Terraform creates a special object called each. This object has two properties you use to fill in the blanks:
each.key: This is the name of the current item (e.g., "public-1").
each.value: This is the data inside that item (e.g., the object containing the cidr and az). */

resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet-${each.key}"
  }
}

# The Route Table Association Loop
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id # This automatically finds the ID for each subnet in the loop
  route_table_id = aws_route_table.public_rt.id
}

# The Private subnet
resource "aws_subnet" "private" {
  for_each                = var.private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-Subnet-${each.key}"
  }
}

#  Request a Public Static IP from AWS
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-gateway-eip"
  }
}
# NAT Gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["public-1"].id

  tags = {
    Name = "${var.environment_name}-ngw"
  }
}

# 4. Route Table (The Rules of the Road)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"            # All traffic...
    nat_gateway_id = aws_nat_gateway.ngw.id # ...goes to the Internet
  }

  tags = {
    Name = "${var.environment_name}-private-rt"
  }
}

# The Route Table Association Loop
# Associate both subnets to this same table to save cost on NAT gateway. We are going to use just Single NAT gateway.
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id # This automatically finds the ID for each subnet in the loop
  route_table_id = aws_route_table.private_rt.id
}