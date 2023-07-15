resource "random_pet" "pet" {
  length = 1
  separator = ""
}

resource "azurerm_storage_account" "resume_storage_account" {
  depends_on = [ azurerm_resource_group.cloud_resume_rg ]
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }

}

resource "null_resource" "blob_upload" {
  depends_on = [azurerm_storage_account.resume_storage_account]
  provisioner "local-exec" {
    command     = <<-EOT
      #!/bin/bash
      az storage blob upload-batch --account-name "${local.storage_account_name}" --destination '$web' --source ./web_files/web 
    EOT
    interpreter = ["bash", "-c"]
  }
}
