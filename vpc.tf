resource "aws_vpc" "JenkinsLab2VPC" {
cidr_block = var.cidr_vpc
instance_tenancy = "default"
tags = {
Name = "VPC-${var.env}"
}
}
