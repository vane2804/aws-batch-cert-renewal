# ===============================
# IAM User
resource "aws_iam_user" "certbot_batch_user" {
  name = "certbot_batch"
}

# ===============================
# S3 Bucket
resource "aws_s3_bucket" "certbot_efs_bucket" {
  bucket = "certbot-efs"
}

# ===============================
# SSM Parameters
resource "aws_ssm_parameter" "access_key_param" {
  name        = "/certbot_batch/access_key"
  type        = "SecureString"
  value       = "dev"
}

resource "aws_ssm_parameter" "secret_key_param" {
  name        = "/certbot_batch/secret_key"
  type        = "SecureString"
  value       = "dev"
}

