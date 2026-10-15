# ---------------------------------------------------------------------------
# Contrato com os outros repositórios (nada sensível aqui; a senha fica só no
# Secrets Manager):
#
#   oficina-api          lê /oficina/<amb>/db/secret-name para montar o Secret
#   oficina-auth-lambda  lê endpoint/porta/nome, secret-arn e sg-id (para abrir
#                        3306 do SG da Lambda para o SG do banco)
# ---------------------------------------------------------------------------
locals {
  parametros = merge([
    for amb in local.ambientes : {
      "/${var.prefixo}/${amb}/db/endpoint"    = aws_db_instance.mysql[amb].address
      "/${var.prefixo}/${amb}/db/porta"       = tostring(aws_db_instance.mysql[amb].port)
      "/${var.prefixo}/${amb}/db/nome"        = aws_db_instance.mysql[amb].db_name
      "/${var.prefixo}/${amb}/db/sg-id"       = aws_security_group.db[amb].id
      "/${var.prefixo}/${amb}/db/secret-arn"  = aws_secretsmanager_secret.db[amb].arn
      "/${var.prefixo}/${amb}/db/secret-name" = aws_secretsmanager_secret.db[amb].name
    }
  ]...)
}

resource "aws_ssm_parameter" "db" {
  for_each = local.parametros

  name  = each.key
  type  = "String"
  value = each.value
}
