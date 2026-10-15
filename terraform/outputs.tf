output "endpoints" {
  description = "Endpoint (host) do RDS por ambiente."
  value       = { for amb in local.ambientes : amb => aws_db_instance.mysql[amb].address }
}

output "porta" {
  value = var.porta
}

output "nome_banco" {
  value = var.nome_banco
}

output "security_groups" {
  description = "SG de cada banco — a Lambda adiciona uma regra de entrada aqui."
  value       = { for amb in local.ambientes : amb => aws_security_group.db[amb].id }
}

output "secrets" {
  description = "Nome do segredo no Secrets Manager com as credenciais, por ambiente."
  value       = { for amb in local.ambientes : amb => aws_secretsmanager_secret.db[amb].name }
}

output "parametros_ssm" {
  description = "Parâmetros publicados no SSM para os outros repositórios."
  value       = sort(keys(local.parametros))
}

output "comando_credenciais" {
  description = "Como obter as credenciais de um ambiente."
  value       = { for amb in local.ambientes : amb => "aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.db[amb].name} --query SecretString --output text" }
}
