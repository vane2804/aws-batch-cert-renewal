variable "environment" { }
variable "region" { }

variable "efs_mt_subnet_id" { }
variable "vpc_id" { }

# Ingress and Egress Rules
variable "default_sg_rule" {
  default = {
    from_port       = null
    to_port         = null
    protocol        = null
    description     = null
    prefix_list_ids = null
    security_groups = null
    self            = null
    cidr_blocks     = null
    ipv6_cidr_blocks = null
  }
}