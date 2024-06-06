# creating vpc
resource "aws_vpc" "vpc_hw2" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "vpc" # here could be inviroment too 
  }
}

# creating internet gateway 
resource "aws_internet_gateway" "hw2_gw" {
  vpc_id = aws_vpc.vpc_hw2.id

  tags = {
    Name = "igw_hw2"
  }
}

#created a data call to get available AZs and then ue them from data call 
data "aws_availability_zones" "available_rn" {
  state = "available"
}

#result_of_this_call == ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
#                           index 0      index 1       index 2        index 3       index 4       index 5

#creating  two public subnets
resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.vpc_hw2.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available_rn.names[2]
  tags = {
    Name = "public_1c"
  }
}

resource "aws_subnet" "public_1d" {
  vpc_id                  = aws_vpc.vpc_hw2.id
  cidr_block              = "10.0.0.64/26"
  map_public_ip_on_launch = true # meaning that we wanna see the IP address 
  availability_zone       = data.aws_availability_zones.available_rn.names[3]
  tags = {
    Name = "public_1d"
  }
}

#creating two private subnets
resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.vpc_hw2.id
  cidr_block              = "10.0.0.128/26"
  map_public_ip_on_launch = false ## this it menas if you wanna see the private IP address , cause its rivate we are not gonna see it 
  availability_zone       = data.aws_availability_zones.available_rn.names[2]
  tags = {
    Name = "private_1c"
  }
}

resource "aws_subnet" "private_1d" {
  vpc_id                  = aws_vpc.vpc_hw2.id
  cidr_block              = "10.0.0.192/26"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available_rn.names[3]
  tags = {
    Name = "private_1d"
  }
}

#NAT gateway creating and for it we need to have elastic IP
#first elastic IP
resource "aws_eip" "elastic_ip" {
  domain   = "vpc_hw2"
}

#NAt gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_1d.id

  tags = {
    Name = "nat_gateway"
  }
}

#building route table for public subnet
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc_hw2.id

  route {
    cidr_block = "0.0.0.0/0"   # this is pointing traffic to internet gateway 
    gateway_id = aws_internet_gateway.hw2_gw.id
  }

  tags = {
    Name = "public_rtb"
  }
}

#building route table for private subnet
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc_hw2.id

  route {
    cidr_block = aws_nat_gateway.nat_gateway.id   # this one pointing trafic to the NAT gateway 
    gateway_id = aws_internet_gateway.hw2_gw.id
  }

  tags = {
    Name = "private_rtb"
  }
}

#created a data call to get ssh key taht we already have 
data "aws_key_pair" "ssh_key" {
  key_name = "tntk"
}


data "aws_ami" "amazon-linux-2" {
 most_recent = true

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}
