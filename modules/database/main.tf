locals {
  create = var.create
}
resource "aws_db_instance" "this" {
  count                = local.create ? 1 : 0
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0"
  identifier           = var.identifier
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  parameter_group_name = "default.mysql8.0"
  # Don't forget these for your private subnet setup!
  db_subnet_group_name   = aws_db_subnet_group.this[count.index].name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot    = true
  storage_encrypted      = true
  tags                   = merge(var.tags, { Name = var.identifier })
}


resource "aws_db_subnet_group" "this" {
  count = local.create ? 1 : 0
  name  = "main_db_subnet_group"
  #subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My DB subnet group"
  }
}

/* resource "aws_ec2_instance_connect_endpoint" "this" {
  
  subnet_id          = var.subnet_ids[0]
  security_group_ids = var.security_group_ids  #[aws_security_group.eice_sg.id]
  preserve_client_ip = false
} */