output "project_name" {
    value = var.project_name
}

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "subnet_ids" {
    value = aws_subnet.subnets[*].id
}

