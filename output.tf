output "az_info" {
    value = data.aws_availability_zones.available
}

output "default_vpc_info" {
    value = data.aws_vpc.default
}

output "default_route_tablle_info" {
    value = data.aws_route_table.main
}