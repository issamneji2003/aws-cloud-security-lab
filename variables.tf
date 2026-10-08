variable "aws_region" {
  description = "Région AWS pour le déploiement des ressources"
  type        = string
  default     = "us-east-1"
}

variable "secure_bucket_name" {
  description = "Nom du bucket S3 principal sécurisé"
  type        = string
  default     = "mon-lab-securite-terraform-issamneji"
}

variable "log_bucket_name" {
  description = "Nom du bucket S3 dédié aux logs"
  type        = string
  default     = "mon-lab-securite-logs-issamneji"
}