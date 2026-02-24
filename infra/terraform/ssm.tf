locals {
  configure_hash = filesha256("${path.module}/scripts/configure.sh")
  configure_b64  = base64encode(file("${path.module}/scripts/configure.sh"))
}

resource "aws_ssm_document" "remake_configure" {
  name          = "${var.project_name}-remake-configure"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Write configure.sh from Terraform, execute it, and mark completion."
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "configure"
        inputs = {
          runCommand = [
            "bash -lc 'set -euo pipefail; mkdir -p /opt; echo \"${local.configure_hash}\" > /opt/remake_configure.hash; echo \"${local.configure_b64}\" | base64 -d > /tmp/configure.sh; chmod +x /tmp/configure.sh; /tmp/configure.sh'"
          ]
        }
      }
    ]
  })
}

resource "aws_ssm_association" "remake_configure_assoc" {
  name = aws_ssm_document.remake_configure.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.web.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_instance.web
  ]
}
