resource "terraform_data" "replacement" {
  input = var.resource_group_name
}

# this is following https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-tool-active-directory
resource "terraform_data" "ad_creation_provisioner" {
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/ad.ps1 -user_name ${var.domain_admin_user} -password \"${var.domain_admin_password}\" -auth_type ${var.authentication_method} -ip ${var.dc_ip} -port ${var.dc_port} -adou_path ${var.adou_path} -domain_fqdn ${var.domain_fqdn} -ifdeleteadou ${var.destory_adou} -deployment_user ${var.deployment_user} -deployment_user_password \"${var.deployment_user_password}\""
    interpreter = ["PowerShell", "-Command"]
  }

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}
