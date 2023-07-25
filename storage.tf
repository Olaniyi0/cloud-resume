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

resource "azurerm_storage_container" "function_blob_container" {
  depends_on = [ azurerm_storage_account.resume_storage_account ]
  name                  = "${local.pet_name}-function-app"
  storage_account_name  = azurerm_storage_account.resume_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "function_blob" {
  depends_on = [ azurerm_storage_container.function_blob_container ]
  name                   = "function_app.zip"
  storage_account_name   = azurerm_storage_account.resume_storage_account.name
  storage_container_name = azurerm_storage_container.function_blob_container.name
  type                   = "Block"
  source                 = "./function_app.zip"
}

data "azurerm_storage_account_sas" "function_app_blob_sas" {
  depends_on = [ azurerm_storage_blob.function_blob ]
  connection_string = azurerm_storage_account.resume_storage_account.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = local.sas_start_time
  expiry = local.sas_expiry_time

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

#################### DATABASE ####################

resource "azurerm_cosmosdb_account" "resume-db" {
  depends_on = [ azurerm_resource_group.cloud_resume_rg ]
  name = "${local.pet_name}-db"
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
  name = "visitors"
  resource_group_name = var.resource_group_name
  account_name = azurerm_cosmosdb_account.resume-db.name
}