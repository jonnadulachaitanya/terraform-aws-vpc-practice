variable "project_name" {
    default = {}
}

variable "environment" {
    default = {}
}


variable "vpc_cidr_block" {
    default = {}
}

variable "enable_dns_hostnames" {
    default = true
}

variable "common_tags" {
    default = {}
}

variable "vpc_tags" {
    default = {}
}

variable "igw_tags" {
    default = {}
}

variable "public_subnet_cidrs" {
    default = ["10.0.1.0/24","10.0.2.0/24"]
}

variable "public_subnet_tags" {
    default = {}
}

variable "private_subnet_cidrs" {
    default = ["10.0.11.0/24","10.0.12.0/24"]
}

variable "private_subnet_tags" {
    default = {}
}

variable "database_subnet_cidrs" {
    default = ["10.0.21.0/24","10.0.22.0/24"]
}

variable "database_subnet_tags" {
    default = {}
}
variable "db_subnet_group_tags" {
    default = {}
}




