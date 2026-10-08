provider "aws" {
  region = var.aws_region
}

# -----------------------------------------------------------------------------
# BUCKET DE LOGS S3
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
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

# -----------------------------------------------------------------------------
# BUCKET PRINCIPAL SÉCURISÉ S3
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.secure_bucket_name
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket                  = aws_s3_bucket.secure_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.secure_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.secure_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

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

# -----------------------------------------------------------------------------
# SÉCURITÉ RÉSEAU & IAM / EC2 (Hardening & Checkov Compliance)
# -----------------------------------------------------------------------------

resource "aws_security_group" "ec2_secure_sg" {
  name        = "ec2-secure-sg"
  description = "Autoriser uniquement le SSH depuis une IP de confiance"

  ingress {
    description = "SSH securise"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.0.2.1/32"]
  }

  egress {
    description = "HTTPS sortant securise"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Rôle IAM minimaliste pour l'instance (requis par Checkov CKV2_AWS_41)
resource "aws_iam_role" "ec2_role" {
  name = "ec2_secure_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_secure_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "secure_ec2" {
  ami                  = "ami-0c7217cdde317cfec"
  instance_type        = "t2.micro"
  ebs_optimized        = true
  monitoring           = true
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  vpc_security_group_ids = [aws_security_group.ec2_secure_sg.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "serveur-securise"
    Environment = "Lab"
  }
# -----------------------------------------------------------------------------
# DÉTECTION AUTOMATISÉE & AUDIT (AWS Config - Requis pour la conformité SOC)
# -----------------------------------------------------------------------------

# Rôle IAM nécessaire pour qu'AWS Config puisse auditer le compte
resource "aws_iam_role" "config_role" {
  name = "aws_config_audit_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Configuration Recorder pour surveiller les changements de ressources
resource "aws_config_configuration_recorder" "recorder" {
  name     = "lab-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resource_types = true
  }
}

# S3 bucket dédié pour stocker les rapports d'évaluation d'AWS Config
resource "aws_s3_bucket" "config_bucket" {
  bucket = "mon-lab-config-bucket-${var.aws_region}"
}

resource "aws_config_delivery_channel" "channel" {
  name           = "lab-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.id
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.channel]
}

# Exemple de règle AWS Config : Vérifier que le chiffrement S3 est actif
resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder_status.recorder_status]
}