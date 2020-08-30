# Create VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.VPC_NAME
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = var.PUBLIC_CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = join(" - ", [var.PUBLIC_CIDR, data.aws_availability_zones.available.names[0]])
  }
}

# Create Private subnet One
resource "aws_subnet" "private_subnet_one" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = lookup(var.PRIVATE_CIDR, "private-1")
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name    = join(" - ", [lookup(var.PRIVATE_CIDR, "private-1"), data.aws_availability_zones.available.names[0]])
    purpose = "k8s-subnet"
  }
}

# Create private Subnet two
resource "aws_subnet" "private_subnet_two" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = lookup(var.PRIVATE_CIDR, "private-2")
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name    = join(" - ", [lookup(var.PRIVATE_CIDR, "private-2"), data.aws_availability_zones.available.names[1]])
    purpose = "k8s-subnet"
  }
}

# Create private subnet three
resource "aws_subnet" "private_subnet_three" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = lookup(var.PRIVATE_CIDR, "private-3")
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name    = join(" - ", [lookup(var.PRIVATE_CIDR, "private-3"), data.aws_availability_zones.available.names[2]])
    purpose = "k8s-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "k8s_gateway" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "K8sInternetGateway"
  }
}

# Creating Route Table for Public Subnet
resource "aws_route_table" "k8s_public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_gateway.id
  }

  tags = {
    Name = "k8s_PublicRoute"
  }

}

# Associating Public subnet to the public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.k8s_public_rt.id
}

# Allocate the Elastic IP for NAT Instance
resource "aws_eip" "nat_ip" {
  vpc = true

  tags = {
    Name = "NATGatewayIP"
  }
}

# Creating NAT Gateway for private subnets.
resource "aws_nat_gateway" "k8s_private_nat_gateway" {
  allocation_id = aws_eip.nat_ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "PrivateSubnetNAT"
  }
}

# Creating Route Table for private task
resource "aws_route_table" "k8s_private_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_private_nat_gateway.id
  }

  tags = {
    Name = "K8sPrivateRoute"
  }
}

# Associating Private subnets to the Private Route Table
resource "aws_route_table_association" "private-1" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.k8s_private_rt.id
}

# Associating Private subnets to the Private Route Table
resource "aws_route_table_association" "private-2" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.k8s_private_rt.id
}

# Associating Private subnets to the Private Route Table
resource "aws_route_table_association" "private-3" {
  subnet_id      = aws_subnet.private_subnet_three.id
  route_table_id = aws_route_table.k8s_private_rt.id
}
