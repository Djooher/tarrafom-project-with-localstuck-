resource "aws_vpc" "aws_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }

}
#public subnet
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "our_subnet"
  }
}


# private subnet 
resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.aws_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "our-private-subnet"
  }
}

#internet getway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.aws_vpc.id

  tags = {
    Name = "internet getway"
  }
}
#route route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws_vpc.id

  route {
    cidr_block = "0.0.0./0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "our route table"
  }
}

#route table association 
resource "aws_route_table_association" "table-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public.id
}
