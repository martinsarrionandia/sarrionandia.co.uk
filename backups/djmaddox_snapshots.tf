resource "aws_dlm_lifecycle_policy" "backup_now" {
  description        = "Immediate backup policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  tags = {
      Name = "Immediate backup"
  }

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Action immediately"

      create_rule {
        cron_expression = local.cron_now
      }

      retain_rule {
        count = 3
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        "Backup" = "immediate"
      }
      copy_tags = true
    }
    target_tags = {
      "backup_now" = "True"
    }
  }  
}

resource "aws_dlm_lifecycle_policy" "backup_monthly" {
  description        = "Monthly backup policy retain 3 backups"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  tags = {
      Name = "Monthly backup"
  }

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "1st day ofthe month retain 6"

      create_rule {
        cron_expression = var.cron_monthly
      }

      retain_rule {
        count = 6
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        "Backup" = "Monthly"
      }
      copy_tags = true
    }
    target_tags = {
      "backup_monthly" = "True"
    }
  }  
}

resource "aws_dlm_lifecycle_policy" "backup_yearly" {
  description        = "Yearly backup policy retain 2 backups"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  tags = {
      Name = "Yearly backup"
  }

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "1st of April every year retain 2"

      create_rule {
        cron_expression = var.cron_yearly_april_1
      }

      retain_rule {
        count = 2
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
        "Backup" = "Yearly"
      }
      copy_tags = true
    }
    target_tags = {
      "backup_yearly" = "True"
    }
  }  
}

locals {
    backup_time = timeadd(timestamp(),"1m")
    minutes = formatdate("m", local.backup_time)
    hours = formatdate("h", local.backup_time)
    day = formatdate("D", local.backup_time)
    month = formatdate("M", local.backup_time)
    year = formatdate("YYYY", local.backup_time)
    cron_now = "cron(${local.minutes} ${local.hours} ${local.day} ${local.month} ? ${local.year})"
}