# ---------------------------------------------------------------------------
# Banco de dados gerenciado: uma instância RDS MySQL 8 por ambiente, nas
# subnets privadas da VPC do projeto, alcançável só pelos nós do EKS (API) e
# pela Lambda de autenticação.
#
# Adaptações ao Learner Lab da AWS Academy:
# - monitoring_interval = 0 e Performance Insights desligado: o Enhanced
#   Monitoring exige uma role IAM, que o lab não deixa criar.
# - deletion_protection = false e skip_final_snapshot = true: o ciclo de uso é
#   "apply no início da sessão, destroy no fim" para poupar crédito.
# - Sem Multi-AZ (dobraria o custo); a alta disponibilidade é documentada como
#   evolução em docs/modelo-de-dados.md.
# ---------------------------------------------------------------------------
resource "aws_db_subnet_group" "db" {
  name        = "${var.prefixo}-db"
  description = "Subnets privadas da VPC ${var.prefixo} para o RDS"
  subnet_ids  = local.subnets_privadas
}

resource "aws_db_parameter_group" "mysql" {
  name_prefix = "${var.prefixo}-mysql8-"
  family      = "mysql8.0"
  description = "utf8mb4 e horario UTC para a API da oficina"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_0900_ai_ci"
  }

  parameter {
    name  = "time_zone"
    value = "UTC"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "db" {
  for_each = local.ambientes

  name        = "${var.prefixo}-${each.key}-db"
  description = "Acesso ao RDS ${each.key}: nos do EKS e Lambda de autenticacao"
  vpc_id      = local.vpc_id

  tags = {
    Name     = "${var.prefixo}-${each.key}-db"
    ambiente = each.key
  }
}

# Nós do EKS (onde a API roda). O SG dos nós é compartilhado pelos namespaces
# hml e prod, então ambos os bancos o liberam.
resource "aws_vpc_security_group_ingress_rule" "db_eks" {
  for_each = local.ambientes

  security_group_id            = aws_security_group.db[each.key].id
  description                  = "MySQL a partir dos nos do EKS"
  referenced_security_group_id = local.sg_nos_eks
  ip_protocol                  = "tcp"
  from_port                    = var.porta
  to_port                      = var.porta
}

# A Lambda (repo oficina-auth-lambda) roda dentro da VPC. Ela cria o próprio SG
# e adiciona uma regra neste SG apontando para ele (id publicado no SSM).

resource "aws_vpc_security_group_egress_rule" "db_saida" {
  for_each = local.ambientes

  security_group_id = aws_security_group.db[each.key].id
  description       = "Saida restrita a VPC"
  cidr_ipv4         = local.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_db_instance" "mysql" {
  for_each = local.ambientes

  identifier = "${var.prefixo}-${each.key}"

  engine         = "mysql"
  engine_version = var.versao_mysql
  instance_class = var.classe_instancia

  allocated_storage     = var.armazenamento_gb
  max_allocated_storage = var.armazenamento_maximo_gb
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.nome_banco
  username = var.usuario_admin
  password = random_password.db[each.key].result
  port     = var.porta

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db[each.key].id]
  parameter_group_name   = aws_db_parameter_group.mysql.name
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = lookup(var.dias_backup, each.key, 1)
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"
  copy_tags_to_snapshot   = true

  monitoring_interval          = 0
  performance_insights_enabled = false

  auto_minor_version_upgrade = true
  apply_immediately          = true
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = {
    Name     = "${var.prefixo}-${each.key}"
    ambiente = each.key
  }
}
