provider "aws" {
  region = "us-east-1"
}

# Bucket de logs sécurisé avec exclusions adaptées pour un lab
# checkov:skip=CKV_AWS_144: "Réplication inter-régions non requise pour ce lab"
# checkov:skip=CKV_AWS_145: "Chiffrement AES256 suffisant pour le stockage de logs de lab"
# checkov:skip=CKV2_AWS_62: "Pas de notifications d'événements nécessaires sur les logs"
resource "aws_s3_bucket" "log_bucket" {
  bucket = "mon-lab-securite-logs-issamneji"
}

resource "aws_s3_bucket_public_access_block" "log_bucket_block" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_encryption" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket principal sécurisé avec exclusions adaptées
# checkov:skip=CKV_AWS_144: "Réplication inter-régions non requise pour ce lab"
# checkov:skip=CKV_AWS_145: "Chiffrement AES256 suffisant pour le lab"
# checkov:skip=CKV2_AWS_62: "Pas de notifications d'événements nécessaires"
resource "aws_s3_bucket" "secure_bucket" {
  bucket = "mon-lab-securite-terraform-issamneji"
}

# Blocage de tous les accès publics
resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Chiffrement par défaut (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Activation du Versionnage S3
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Activation des logs d'accès
resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

# Configuration du cycle de vie
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Politique de compartiment pour exiger le HTTPS (TLS)
resource "aws_s3_bucket_policy" "enforce_ssl" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLSRequestsOnly"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_bucket.arn,
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}