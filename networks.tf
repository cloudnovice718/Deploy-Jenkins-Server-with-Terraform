# Create a VPC called "VPC Alpha" in the us-east-1 region
resource "aws_vpc" "vpc_alpha" {
  provider             = aws.region-alpha
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "region_alpha_vpc"
  }
}

# Create a VPC called "VPC Bravo" in the us-west-2 region
resource "aws_vpc" "vpc_bravo" {
  provider             = aws.region-bravo
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "region_bravo_vpc"
  }
}

# Create an IGW for VPC Alpha
resource "aws_internet_gateway" "igw_alpha" {
  provider = aws.region-alpha
  vpc_id   = aws_vpc.vpc_alpha.id
  tags = {
    Name = "region_alpha_igw"
  }
}

# Create an IGW for VPC Bravo
resource "aws_internet_gateway" "igw_bravo" {
  provider = aws.region-bravo
  vpc_id   = aws_vpc.vpc_bravo.id
  tags = {
    Name = "region_bravo_igw"
  }
}

# Fetch information about all availability zones in VPC Alpha
data "aws_availability_zones" "my_azs" {
  provider = aws.region-alpha
  state    = "available"
}

# Create a subnet for the first availability zone in VPC Alpha
resource "aws_subnet" "subnet_1_alpha" {
  provider          = aws.region-alpha
  availability_zone = element(data.aws_availability_zones.my_azs.names, 0)
  vpc_id            = aws_vpc.vpc_alpha.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "region_alpha_subnet_1"
  }
}

# Create a subnet for the 2nd availability zone in VPC Alpha
resource "aws_subnet" "subnet_2_alpha" {
  provider          = aws.region-alpha
  availability_zone = element(data.aws_availability_zones.my_azs.names, 1)
  vpc_id            = aws_vpc.vpc_alpha.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "region_alpha_subnet_2"
  }
}

# Create a subnet for VPC Bravo
resource "aws_subnet" "subnet_1_bravo" {
  provider   = aws.region-bravo
  vpc_id     = aws_vpc.vpc_bravo.id
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "region_bravo_subnet_1"
  }
}

# Initiate a peering request from VPC Alpha to VPC Bravo
resource "aws_vpc_peering_connection" "vpc_alpha_to_vpc_bravo" {
  provider    = aws.region-alpha
  peer_vpc_id = aws_vpc.vpc_bravo.id
  vpc_id      = aws_vpc.vpc_alpha.id
  peer_region = var.region-bravo
  tags = {
    Name = "region_alpha_peering_connection"
  }
}

# Accept the peering request from VPC Alpha
resource "aws_vpc_peering_connection_accepter" "accept_peering_request" {
  provider                  = aws.region-bravo
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_alpha_to_vpc_bravo.id
  auto_accept               = true
  tags = {
    Name = "region_bravo_peering_connection"
  }
}

# Create a route table for VPC Alpha
resource "aws_route_table" "vpc_alpha_rt" {
  provider = aws.region-alpha
  vpc_id   = aws_vpc.vpc_alpha.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_alpha.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_alpha_to_vpc_bravo.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "vpc_alpha_route_table"
  }
}

# Replace default route table settings for VPC Alpha with new entries
resource "aws_main_route_table_association" "vpc_alpha_rt_assoc" {
  provider       = aws.region-alpha
  vpc_id         = aws_vpc.vpc_alpha.id
  route_table_id = aws_route_table.vpc_alpha_rt.id
}

# Create a route table for VPC Bravo
resource "aws_route_table" "vpc_bravo_rt" {
  provider = aws.region-bravo
  vpc_id   = aws_vpc.vpc_bravo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_bravo.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.vpc_alpha_to_vpc_bravo.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "vpc_bravo_route_table"
  }
}

# Replace default route table settings for VPC Bravo with new entries
resource "aws_main_route_table_association" "vpc_bravo_rt_assoc" {
  provider       = aws.region-bravo
  vpc_id         = aws_vpc.vpc_bravo.id
  route_table_id = aws_route_table.vpc_bravo_rt.id
}