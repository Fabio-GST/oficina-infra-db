# ---------------------------------------------------------------------------
# Credenciais do banco: senha gerada aqui e entregue aos consumidores pelo
# Secrets Manager (oficina/<ambiente>/db). O CD do repo oficina-api lê este
# segredo e monta o Secret do Kubernetes; a Lambda lê em tempo de execução.
# recovery_window_in_days = 0 permite recriar o segredo com o mesmo nome logo
# após um destroy (ciclo de sessões do lab).
# ---------------------------------------------------------------------------
resource "random_password" "db" {
  for_each = local.ambientes

  length           = 32
  special          = true
  override_special = "!#%^*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  for_each = local.ambientes

  name                    = "${var.prefixo}/${each.key}/db"
  description             = "Credenciais do RDS MySQL ${each.key} da oficina"
  recovery_window_in_days = 0

  tags = {
    ambiente = each.key
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  for_each = local.ambientes

  secret_id = aws_secretsmanager_secret.db[each.key].id
  secret_string = jsonencode({
    engine   = "mysql"
    host     = aws_db_instance.mysql[each.key].address
    port     = aws_db_instance.mysql[each.key].port
    dbname   = aws_db_instance.mysql[each.key].db_name
    username = aws_db_instance.mysql[each.key].username
    password = random_password.db[each.key].result
    # Chaves no formato das variáveis de ambiente da API (Lucid/AdonisJS).
    DB_HOST     = aws_db_instance.mysql[each.key].address
    DB_PORT     = tostring(aws_db_instance.mysql[each.key].port)
    DB_DATABASE = aws_db_instance.mysql[each.key].db_name
    DB_USER     = aws_db_instance.mysql[each.key].username
    DB_PASSWORD = random_password.db[each.key].result
  })
}
