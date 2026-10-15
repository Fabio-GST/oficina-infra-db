terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Estado remoto no mesmo bucket/tabela dos outros repos, com key própria.
  # Os valores vêm de `-backend-config` (arquivo backend.hcl) — ver README.
  backend "s3" {}
}

provider "aws" {
  region = var.regiao

  default_tags {
    tags = {
      projeto     = "oficina"
      repositorio = "oficina-infra-db"
      gerenciado  = "terraform"
    }
  }
}
