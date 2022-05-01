data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.path
  }
} 

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
} 

provider "aws" {
  region     = var.region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

resource "aws_s3_bucket" "jhooq-s3-bucket" {
  bucket = "jhooq-s3-bucket"
  acl = "private" 
}
resource "aws_s3_bucket_object" "object1" {
  for_each = fileset("uploads/", "*")
  bucket = aws_s3_bucket.jhooq-s3-bucket.id
  key = each.value
  source = "uploads/${each.value}"
}
 
resource "aws_s3_bucket_public_access_block" "app" {
 bucket = aws_s3_bucket.jhooq-s3-bucket.id
 
 block_public_acls       = true
 block_public_policy     = true
 ignore_public_acls      = true
 restrict_public_buckets = true
} 
