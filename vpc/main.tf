# create vpc
resource "aws_vpc" "vpc" {
  cidr_block              = var.vpc_cidr
  enable_dns_hostnames    = true

  tags      = {
    Name    = "${var.project_name}-vpc"
  }
}

# create internet gateway and attach it to vpc
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    Name    = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "subnets" {
  count                   = length(var.subnet_cidr_block)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.subnet_cidr_block, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = element(var.assign_public_ip, count.index)

  tags      = {
    Name    = element(var.tags, count.index)
  }
}

# create route table and add public route
resource "aws_route_table" "public_route_table" {
  vpc_id       = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags       = {
    Name     = "pub route table"
  }
}

# associate public subnet "public route table"
resource "aws_route_table_association" "public_route_table_association1" {
  count = 1
  subnet_id           = aws_subnet.subnets[0].id
  route_table_id      = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_route_table_association2" {
  count = 1
  subnet_id           = aws_subnet.subnets[1].id
  route_table_id      = aws_route_table.public_route_table.id
} 

#creating eip and allocating it to  NAT 1
resource "aws_eip" "eip_nat_gateway_1" {
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.eip_nat_gateway_1.id
  subnet_id     = aws_subnet.subnets[0].id
}

#creatng eip and allocating it to NAT 2
resource "aws_eip" "eip_nat_gateway_2" {
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.eip_nat_gateway_2.id
  subnet_id     = aws_subnet.subnets[1].id
}

#creating route table 
#private rt
resource "aws_route_table" "priv_rt_1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat_gateway_1.id
  }
  tags = {
    Name = "priv rt"
  }
}

#route table association 
resource "aws_route_table_association" "private_app_association_az1" {

  subnet_id      = aws_subnet.subnets[2].id
  route_table_id = aws_route_table.priv_rt_1.id
}

resource "aws_route_table_association" "private_db_association_az1" {

  subnet_id      = aws_subnet.subnets[3].id
  route_table_id = aws_route_table.priv_rt_1.id
}

#creating route table 
#private rt
resource "aws_route_table" "priv_rt_2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block       = "0.0.0.0/0"
    nat_gateway_id   = aws_nat_gateway.nat_gateway_2.id
  }
  tags = {
    Name = "privrt 2"
  }
}

#route table association
resource "aws_route_table_association" "private_app_association" {

  subnet_id      = aws_subnet.subnets[4].id
  route_table_id = aws_route_table.priv_rt_2.id
}

resource "aws_route_table_association" "private_db_association" {

  subnet_id      = aws_subnet.subnets[5].id
  route_table_id = aws_route_table.priv_rt_2.id
}


