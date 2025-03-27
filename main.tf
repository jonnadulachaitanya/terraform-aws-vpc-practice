resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames

    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.igw_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id 
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true

    tags = merge(
        var.common_tags,
        var.public_subnet_tags,
        {
            Name = "${local.resource_name}-public-${local.az_names[count.index]}"
        }
    )

}

resource "aws_subnet" "private" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id 
    availability_zone = local.az_names[count.index]

    tags = merge(
        var.common_tags,
        var.private_subnet_tags,
        {
            Name = "${local.resource_name}-private-${local.az_names[count.index]}"
        }
    )

}

resource "aws_subnet" "database" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.main.id 
    availability_zone = local.az_names[count.index]

    tags = merge(
        var.common_tags,
        var.database_subnet_tags,
        {
            Name = "${local.resource_name}-database-${local.az_names[count.index]}"
        }
    )

}

# DB subnet group for RDS

resource "aws_db_subnet_group" "database" {
    name = local.resource_name
    subnet_ids = aws_subnet.database[*].id

    tags = merge(
        var.common_tags,
        var.db_subnet_group_tags,
        {
            Name = local.resource_name
        }
    )

}

## we need to create route table but NAT gateway also need to set up in route and EIP is dependecy for NAT.
resource "aws_eip" "eip_nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
    vpc_id = aws_vpc.main.id
    subnet_ids = aws_subnet.public.id
    

    tags = merge(
        var.common_tags,
        var.aws_nat_gateway_tags,
        {
            Name = local.resource_name
        }
    )

    ## To ensure proper ordering, it is recommended to add an explicit dependency
    ## On the internet gateway for the VPC
    depends_on = [aws_internet_gateway.main]
}

# Route tables

resource "aws_route_table" "public" {
    subnet_ids = aws
}