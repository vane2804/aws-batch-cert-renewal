# ===============================
# DATA VPC
data "aws_vpc" "vpc" {
  id = var.vpc_id
}


# ===============================
# EFS
resource "aws_efs_file_system" "cert_efs" {
  tags = {
    Name = local.efs_name
  }
}

# ===============================
# EFS Mount Target
resource "aws_efs_mount_target" "cert_efs" {
  file_system_id = aws_efs_file_system.cert_efs.id
  subnet_id      = var.efs_mt_subnet_id
  security_groups = [aws_security_group.efs_sg.id]
}

# ===============================
# EFS Access Point
resource "aws_efs_access_point" "cert_efs_ap" {
  file_system_id = aws_efs_file_system.cert_efs.id
  
  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid = 0
      owner_uid = 0
      permissions = 777
    }
  }

  tags = {
    Name = "${local.efs_name}-AP"
  }
}

# ===============================
# EFS Security Group
resource "aws_security_group" "efs_sg" {
  vpc_id      = var.vpc_id
  name        = local.efs_sg_name
  description = "Cert EFS SG"

  tags = {
    Name = local.efs_sg_name
  }

  ingress = [
    merge(
      var.default_sg_rule,  
      {
        protocol     = "tcp",
        cidr_blocks  = [data.aws_vpc.vpc.cidr_block],
        from_port    = 2049,
        to_port      = 2049
      }
    ),
    merge(
      var.default_sg_rule,  
      {
        protocol    = "tcp",
        cidr_blocks = [data.aws_vpc.vpc.cidr_block],
        from_port   = 80,
        to_port     = 80
      }
    ),
    merge(
      var.default_sg_rule,  
      {
        protocol    = "tcp",
        cidr_blocks = [data.aws_vpc.vpc.cidr_block],
        from_port   = 443,
        to_port     = 443
      }
    ),
    merge(
      var.default_sg_rule,  
      {
        protocol    = "tcp",
        cidr_blocks = [data.aws_vpc.vpc.cidr_block],
        from_port   = 22,
        to_port     = 22
      }
    )
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}