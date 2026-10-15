variable "regiao" {
  description = "Região AWS. O Learner Lab da AWS Academy libera us-east-1."
  type        = string
  default     = "us-east-1"
}

variable "ambientes" {
  description = "Ambientes que recebem uma instância RDS própria. Reduza para [\"hml\"] em sessões de teste para economizar crédito."
  type        = list(string)
  default     = ["hml", "prod"]
}

variable "prefixo" {
  description = "Prefixo dos nomes de recursos e dos parâmetros no SSM (/<prefixo>/<ambiente>/db/*)."
  type        = string
  default     = "oficina"
}

variable "versao_mysql" {
  description = "Versão do engine MySQL."
  type        = string
  default     = "8.0"
}

variable "classe_instancia" {
  description = "Classe da instância RDS. db.t3.micro cabe no free tier e atende a demonstração."
  type        = string
  default     = "db.t3.micro"
}

variable "armazenamento_gb" {
  description = "Armazenamento alocado (GB). 20 é o mínimo do gp3."
  type        = number
  default     = 20
}

variable "armazenamento_maximo_gb" {
  description = "Teto do autoescalonamento de armazenamento (GB). 0 desliga."
  type        = number
  default     = 50
}

variable "nome_banco" {
  description = "Nome do schema criado na instância (o mesmo em todos os ambientes; cada ambiente tem sua instância)."
  type        = string
  default     = "oficina"
}

variable "usuario_admin" {
  description = "Usuário mestre do banco. A senha é gerada e guardada no Secrets Manager."
  type        = string
  default     = "oficina_admin"
}

variable "dias_backup" {
  description = "Dias de retenção de backup automático por ambiente."
  type        = map(number)
  default = {
    hml  = 1
    prod = 7
  }
}

variable "porta" {
  description = "Porta do MySQL."
  type        = number
  default     = 3306
}
