
#CREATING VPC______________________________________________________________________________________________________________________________________________________________
resource "aws_vpc" "apci_main_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-vpc"
  })
}

#CREATING INTERNET GATEWAY__________________________________________________________________________________________________________________________________
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.apci_main_vpc.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}

# CREATING FRONTEND SUBNETS__________________________________________________________________________________________________________________________________
resource "aws_subnet" "frontend-subnet-az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[0]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-subnet-az1a"
  })
}


resource "aws_subnet" "frontend-subnet-az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.frontend_cidr_block[1]
  availability_zone = var.availability_zone[1]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-frontend-subnet-az1b"
  })
}

# CREATING BACKEND SUBNETS__________________________________________________________________________________________________________________________________
resource "aws_subnet" "backend-subnet-az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[0]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az1a"
  })
}

resource "aws_subnet" "backend-subnet-az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[1]
  availability_zone = var.availability_zone[1]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-backend-subnet-az1b"
  })
}

# CREATING DB SUBNETS__________________________________________________________________________________________________________________________________
resource "aws_subnet" "db-subnet-az1a" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[2]
  availability_zone = var.availability_zone[0]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
  })
}

resource "aws_subnet" "db-subnet-az1b" {
  vpc_id     = aws_vpc.apci_main_vpc.id
  cidr_block = var.backend_cidr_block[3]
  availability_zone = var.availability_zone[1]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az1b"
  })
}

#CREATING PUBLIC ROUTE TABLE__________________________________________________________________________________________________________________________________
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public_rt"
  })
}

#CREATING FRONTEND ROUTE TABLE ASSOCIATION__________________________________________________________________________________________________________________________________
resource "aws_route_table_association" "frontend-subnet-az1a" {
  subnet_id      = aws_subnet.frontend-subnet-az1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "frontend-subnet-az1b" {
  subnet_id      = aws_subnet.frontend-subnet-az1b.id
  route_table_id = aws_route_table.public_rt.id
}
  
#CREATING ELASTIC IP FOR AZ1A__________________________________________________________________________________________________________________________________
resource "aws_eip" "eip" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip"
  })
}

#CREATING NAT GATEWAY FOR AZ1A__________________________________________________________________________________________________________________________________
resource "aws_nat_gateway" "nat_gw_az1a" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.frontend-subnet-az1a.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip, aws_subnet.frontend-subnet-az1a]
}

#CREATING PRIVATE ROUTE TABLE FOR AZ1A__________________________________________________________________________________________________________________________________
resource "aws_route_table" "private_rt_az1a" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az1a.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1a"
  })
}

#CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ1A__________________________________________________________________________________________________________________________________
resource "aws_route_table_association" "backend-subnet-az1a" {
  subnet_id      = aws_subnet.backend-subnet-az1a.id
  route_table_id = aws_route_table.private_rt_az1a.id
}


resource "aws_route_table_association" "db-subnet-az1a" {
  subnet_id      = aws_subnet.db-subnet-az1a.id
  route_table_id = aws_route_table.private_rt_az1a.id
}

#CREATING ELASTIC IP FOR AZ1B__________________________________________________________________________________________________________________________________
resource "aws_eip" "eip_az1b" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip_az1b"
  })
}

#CREATING NAT GATEWAY FOR AZ1B__________________________________________________________________________________________________________________________________
resource "aws_nat_gateway" "nat_gw_az1b" {
  allocation_id = aws_eip.eip_az1b.id
  subnet_id     = aws_subnet.frontend-subnet-az1b.id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat_gw_az1b"
  })

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az1b, aws_subnet.frontend-subnet-az1b]
}

#CREATING PRIVATE ROUTE TABLE FOR AZ1B__________________________________________________________________________________________________________________________________
resource "aws_route_table" "private_rt_az1b" {
  vpc_id = aws_vpc.apci_main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az1b.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private_rt_az1b"
  })
}

#CREATING PRIVATE ROUTE TABLE ASSOCIATION FOR AZ1B__________________________________________________________________________________________________________________________________
resource "aws_route_table_association" "backend-subnet-az1b" {
  subnet_id      = aws_subnet.backend-subnet-az1b.id
  route_table_id = aws_route_table.private_rt_az1b.id
}


resource "aws_route_table_association" "db-subnet-az1b" {
  subnet_id      = aws_subnet.db-subnet-az1b.id
  route_table_id = aws_route_table.private_rt_az1b.id
}