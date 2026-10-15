# ---------------------------------------------------------------------------
# Contrato com o repo oficina-infra-k8s: a VPC, as subnets privadas e o
# security group dos nós do EKS são lidos do SSM Parameter Store, publicados
# por aquele repositório. Os states permanecem independentes.
# ---------------------------------------------------------------------------
data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefixo}/vpc/id"
}

data "aws_ssm_parameter" "vpc_cidr" {
  name = "/${var.prefixo}/vpc/cidr"
}

data "aws_ssm_parameter" "subnets_privadas" {
  name = "/${var.prefixo}/vpc/subnets-privadas"
}

data "aws_ssm_parameter" "sg_nos_eks" {
  name = "/${var.prefixo}/eks/sg-nos"
}

locals {
  ambientes        = toset(var.ambientes)
  vpc_id           = data.aws_ssm_parameter.vpc_id.value
  vpc_cidr         = data.aws_ssm_parameter.vpc_cidr.value
  subnets_privadas = split(",", data.aws_ssm_parameter.subnets_privadas.value)
  sg_nos_eks       = data.aws_ssm_parameter.sg_nos_eks.value
}
