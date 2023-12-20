terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-sophnel"
    key            = "fintech"
    region         = "eu-central-1"
    dynamodb_table = "fintech-terraform-lock"
    encrypt        = true
  }
}
