resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [var.db-subnet-az1a-id, var.db-subnet-az1b-id]

      tags = merge(var.tags,{
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
  })
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow db traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_access" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = var.vpc_cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  db_name              = "rdsmysql"
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  multi_az = true
  publicly_accessible  = false
  storage_type         = "gp2"
#   backup_retention_period = 0
#   backup_window = "00:00-00:10" # window for frequent backups set to every 10 minutes
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id] # rds security group ID
  
#   # Specify an S3 bucket for backups
#   s3_import {
#     bucket_name = "mysql-automated-backup"
#     source_engine = "mysql"
#     source_engine_version = "8.0"
#     ingestion_role = aws_iam_role.s3RDS_backup.arn
#   }

#   iam_database_authentication_enabled = true
  


   tags = merge(var.tags,{
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds_mysql"
  })
}