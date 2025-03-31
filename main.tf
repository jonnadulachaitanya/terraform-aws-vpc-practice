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
    cidr_block = var.public_subnet_cidrs[count.index]
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
    cidr_block = var.private_subnet_cidrs[count.index]

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
    cidr_block = var.database_subnet_cidrs[count.index]

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

    tags = merge(
        var.common_tags,
        var.eip_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.eip_nat.id
    subnet_id = aws_subnet.public[0].id
    

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
    vpc_id = aws_vpc.main.id

    
    tags = merge(
        var.common_tags,
        var.public_route_table_tags,
        {
            Name = "${local.resource_name}-public"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.private_route_table_tags,
        {
            Name = "${local.resource_name}-private"
        }
    )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.common_tags,
        var.database_route_table_tags,
        {
            Name = "${local.resource_name}-database"
        }
    )
}

# Routes
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route" "database" {
    route_table_id = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
}

# Route table association

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
} 

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}



