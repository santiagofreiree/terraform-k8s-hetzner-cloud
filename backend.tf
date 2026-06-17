# Terraform Backend Configuration
# Uncomment and configure for remote state storage
# This enables team collaboration and state locking

# Example: Hetzner Object Storage (S3-compatible)
# terraform {
#   backend "s3" {
#     bucket = "your-terraform-state-bucket"
#     key    = "worker0/terraform.tfstate"
#     region = "nbg1"
#     
#     # Hetzner Object Storage endpoint
#     endpoints = {
#       s3 = "https://nbg1.your-object-storage.com"
#     }
#     
#     # S3-compatible settings
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     skip_requesting_account_id  = true
#     use_path_style              = true
#   }
# }

# Alternative: AWS S3 with DynamoDB locking
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "worker0/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }

# Alternative: Terraform Cloud
# terraform {
#   backend "remote" {
#     hostname     = "app.terraform.io"
#     organization = "your-organization"
#     
#     workspaces {
#       name = "worker0-prod"
#     }
#   }
# }
