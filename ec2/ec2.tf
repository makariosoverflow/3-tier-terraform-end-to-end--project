resource "aws_security_group" "bastion_host_sg" {
  name        = "bastion-host-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-host-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_access" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "13.48.4.200/30"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.bastion_host_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create a Bastion Host EC2 instance
resource "aws_instance" "bastion_host" {
  ami = var.image_id
  subnet_id = var.frontend-subnet-az1a
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  key_name = var.key_name
  associate_public_ip_address = true
  
  instance_type = var.instance_type
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-bastion-host"
  })
}


# Create a Private Server Security Group
resource "aws_security_group" "private_server_sg" {
  name        = "private-server-sg"
  description = "Allow SSH traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "private-server-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.private_server_sg.id
  referenced_security_group_id = aws_security_group.bastion_host_sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.private_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Create a Private Server in AZ 1A
resource "aws_instance" "private_server_az1a" {
  ami = var.image_id
  subnet_id = var.backend-subnet-az1a
  vpc_security_group_ids = [aws_security_group.private_server_sg.id]
  key_name = var.key_name
  associate_public_ip_address = false
  
  instance_type = var.instance_type
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az1a"
  })
}

# Create a Private Server in AZ 1B
resource "aws_instance" "private_server_az1b" {
  ami = var.image_id
  subnet_id = var.backend-subnet-az1b
  vpc_security_group_ids = [aws_security_group.private_server_sg.id]
  key_name = var.key_name
  associate_public_ip_address = false
  
  instance_type = var.instance_type
 tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-server-az1b"
  })
}

