resource "random_pet" "pet" {
  length    = 1
  separator = ""
}

resource "azurerm_storage_account" "resume_storage_account" {
  depends_on               = [azurerm_resource_group.cloud_resume_rg]
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


#################### DATABASE ####################

resource "azurerm_cosmosdb_account" "resume-db" {
  depends_on = [ azurerm_resource_group.cloud_resume_rg ]
  name = "${local.storage_account_name}-db"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  enable_automatic_failover = false
  enable_free_tier = true


  capabilities {
    name = "EnableTable"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location = "uksouth"
    failover_priority = 0
  }

  backup {
    type = "Periodic"
    interval_in_minutes = 240
    retention_in_hours = 8
    storage_redundancy = "Local"
  }
}

resource "azurerm_cosmosdb_table" "resumes-db" {
  depends_on = [ azurerm_cosmosdb_account.resume-db ]
  name = "${local.storage_account_name}-visitorsCount"
  resource_group_name = var.resource_group_name
  account_name = azurerm_cosmosdb_account.resume-db.name
}