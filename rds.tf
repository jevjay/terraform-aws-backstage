resource "random_password" "database" {
  count   = var.create_database && var.database_credentials.password == null ? 1 : 0
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "database_password" {
  count = var.create_database ? 1 : 0

  name        = "${local.name_prefix}-db-password"
  description = "Backstage database password"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "database_password" {
  count = var.create_database ? 1 : 0

  secret_id     = aws_secretsmanager_secret.database_password[0].id
  secret_string = var.database_credentials.password != null ? var.database_credentials.password : random_password.database[0].result
}

resource "aws_db_subnet_group" "backstage" {
  count = var.create_database ? 1 : 0

  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = length(var.existing_private_subnet_ids) > 0 ? var.existing_private_subnet_ids : module.vpc[0].private_subnets

  tags = local.tags
}

resource "aws_db_instance" "backstage" {
  count = var.create_database ? 1 : 0

  identifier        = "${local.name_prefix}-db"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = var.database_instance_class
  allocated_storage = var.database_allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "backstage"
  username = var.database_credentials.username
  password = var.database_credentials.password != null ? var.database_credentials.password : random_password.database[0].result
  port     = 5432

  vpc_security_group_ids = [aws_security_group.backstage_db.id]
  db_subnet_group_name   = aws_db_subnet_group.backstage[0].name

  backup_retention_period    = 7
  backup_window              = "03:00-04:00"
  maintenance_window         = "Mon:04:00-Mon:05:00"
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = local.tags
}
