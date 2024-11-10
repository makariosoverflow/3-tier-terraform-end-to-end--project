output "vpc_id" {
  value = aws_vpc.apci_main_vpc.id
}
output "vpc_cidr_block" {
  value = aws_vpc.apci_main_vpc.cidr_block
}
output "frontend-subnet-az1a" {
  value = aws_subnet.frontend-subnet-az1a.id
}

output "frontend-subnet-az1b" {
  value = aws_subnet.frontend-subnet-az1b.id
}

output "backend-subnet-az1a" {
  value = aws_subnet.backend-subnet-az1a.id
}

output "backend-subnet-az1b" {
  value = aws_subnet.backend-subnet-az1b.id
}

output "db-subnet-az1b-id" {
  value = aws_subnet.db-subnet-az1b.id
}

output "db-subnet-az1a-id" {
  value = aws_subnet.db-subnet-az1a.id
}