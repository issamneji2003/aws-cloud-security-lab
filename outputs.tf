output "secure_bucket_arn" {
  description = "ARN du bucket S3 principal"
  value       = aws_s3_bucket.secure_bucket.arn
}

output "log_bucket_arn" {
  description = "ARN du bucket S3 de logs"
  value       = aws_s3_bucket.log_bucket.arn
}

output "secure_bucket_domain_name" {
  description = "Nom de domaine du bucket principal"
  value       = aws_s3_bucket.secure_bucket.bucket_domain_name
}