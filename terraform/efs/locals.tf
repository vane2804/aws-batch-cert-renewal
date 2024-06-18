locals {
  efs_name = upper("${var.environment}-CERT-EFS")
  efs_sg_name = upper("${var.environment}-EFS-SG")
}