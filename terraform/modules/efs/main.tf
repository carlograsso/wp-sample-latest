resource "aws_efs_file_system" "this" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    "Name" = "${var.project}-${var.name}"
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnets)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnets[count.index]
  security_groups = var.security_groups
}


resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
  posix_user {
    gid = var.user_gid
    uid = var.user_uid
  }
  root_directory {
    path = var.efs_ap_path

    creation_info {
      owner_gid   = var.owner_gid
      owner_uid   = var.owner_uid
      permissions = var.efs_ap_permissions
    }
  }
}