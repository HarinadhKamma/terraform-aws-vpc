resource "aws_vpc_peering_connection" "main" {
  count = var.vpc_peering_connection ? 1 : 0
  # peer_owner_id = var.peer_owner_id
  peer_vpc_id = data.aws_vpc.default.id
  vpc_id      = aws_vpc.main.id
  auto_accept = true

  tags = merge(local.common_tags,
    var.igw_tags,
    {
      Name = "${local.common_name}-vpcpeering"
  })
}


resource "aws_route" "public_peering" {
  count                     = var.vpc_peering_connection ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

resource "aws_route" "default_peering" {
  count                     = var.vpc_peering_connection ? 1 : 0
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

resource "aws_route" "private_peering" {
  count                     = var.vpc_peering_connection ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.main[count.index].id
}

