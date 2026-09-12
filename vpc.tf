resource "aws_vpc" "mainVPC" {
cidr_block = var.cidr_vpc
instance_tenancy = "default"
tags = {
Name = "VPC-${var.env}"
}
}