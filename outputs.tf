output "s3_bucket_arn" {
  description = "L'ARN du compartiment S3 sécurisé"
  value       = aws_s3_bucket.secure_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "L'URL du compartiment S3"
  value       = aws_s3_bucket.secure_bucket.bucket_domain_name
}