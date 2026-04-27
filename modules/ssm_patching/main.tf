# 1. The Rulebook (Baseline)
resource "aws_ssm_patch_baseline" "this" {
  name             = "${var.patch_group_name}-baseline"
  operating_system = "AMAZON_LINUX_2" # Change this if you use Ubuntu/Windows

  approval_rule {
    approve_after_days = 7
    compliance_level   = "CRITICAL"
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix"]
    }
    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }
}

# 2. The Association (Links Baseline to the Tag)
resource "aws_ssm_patch_group" "this" {
  baseline_id = aws_ssm_patch_baseline.this.id
  patch_group = var.patch_group_name
}

# 3. The Window (When to run)
resource "aws_ssm_maintenance_window" "this" {
  name     = "${var.patch_group_name}-window"
  schedule = var.scan_schedule
  duration = 3
  cutoff   = 1
}

# Only make it default if the environment is 'Prod'
resource "aws_ssm_default_patch_baseline" "this" {
  count            = var.environment == "Prod" ? 1 : 0
  baseline_id      = aws_ssm_patch_baseline.this.id
  operating_system = "AMAZON_LINUX_2"
}

resource "aws_ssm_maintenance_window_target" "this" {
  window_id     = aws_ssm_maintenance_window.this.id
  name          = "${var.patch_group_name}-target"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:PatchGroup" # Using the fixed tag key!
    values = [var.patch_group_name]
  }
}

resource "aws_ssm_maintenance_window_task" "patching" {
  max_concurrency = "2"
  max_errors      = "1"
  priority        = 1
  task_arn        = "AWS-RunPatchBaseline" # The script we just used
  task_type       = "RUN_COMMAND"
  window_id       = aws_ssm_maintenance_window.this.id

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.this.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"] # Crucial: Must be Install, not Scan
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}