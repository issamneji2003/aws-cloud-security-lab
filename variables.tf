variable "aws_region" {
  description = "La région AWS cible pour le déploiement"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_name" {
  description = "Le nom unique du compartiment S3 sécurisé"
  type        = string
  default     = "mon-lab-securite-terraform-issamneji"
}