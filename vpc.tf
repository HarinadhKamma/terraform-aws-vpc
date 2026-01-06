resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(local.common_tags,
    {
      Name = local.common_name
  })
}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags,
    var.igw_tags,
    {
      Name = local.common_name
  })
}

#public subnet cidr range
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main.id
  count  = length(var.public_subnet_cidr)
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
  })
}


#private subnet cidr range
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_subnet_cidr)
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = local.az_names[count.index]

  tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-private-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
  })
}

#database subnet cidr range
resource "aws_subnet" "database_subnet" {
  vpc_id = aws_vpc.main.id
  count  = length(var.database_subnet_cidr)
  cidr_block              = var.database_subnet_cidr[count.index]
  availability_zone       = local.az_names[count.index]

  tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-database-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
  })
}

#public route table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
 tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-public" # roboshop-dev-public
  })
}

#private route table 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
 tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-private" # roboshop-dev-public
  })
}

#database route table 
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
 tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-database" # roboshop-dev-public
  })
}

# public subnet mapping
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Elastic IP
resource "aws_eip" "eip_for_server" {
  domain   = "vpc" # Specifies that the EIP is for use in a VPC (default)
  tags =  merge(local.common_tags,

    {
      Name = "${local.common_name}-eip" # roboshop-dev-public
  })
}

#NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip_for_server.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(local.common_tags,

    {
      Name = "${local.common_name}-nat" # roboshop-dev-public
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# private subnet mapping
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id    = aws_nat_gateway.nat.id
}

# database subnet mapping
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id    = aws_nat_gateway.nat.id
}

# public Route table association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# public Route table association
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

# public Route table association
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database.id
}