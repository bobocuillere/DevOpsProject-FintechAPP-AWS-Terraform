provider "aws" {
  region = var.aws_region
  
}

provider "aws" {
  alias  = "secretsmanager"
  region = var.aws_secrets_manager_region
}
