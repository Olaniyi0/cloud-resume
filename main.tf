terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.60.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "cloud_resume_rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# resource "azurerm_storage_account" "function_storage_account" {
#   depends_on = [ azurerm_resource_group.cloud_resume_rg ]
#   name = var.storage_account_name
#   resource_group_name = var.resource_group_name
#   location = var.resource_group_location
#   account_tier  = "Standard"
#   account_replication_type = "LRS"
# }

# resource "azurerm_service_plan" "function_service_plan" {
#   depends_on = [ azurerm_resource_group.cloud_resume_rg ]
#   name = var.service_plan_name
#   location = var.resource_group_location
#   resource_group_name = var.resource_group_name
#   os_type = "Linux"
#   sku_name = "Y1"
# }

# resource "azurerm_linux_function_app" "my_function" {
#   depends_on = [ azurerm_resource_group.cloud_resume_rg ]
#   name = var.function_app_name
#   resource_group_name = var.resource_group_name
#   location = var.resource_group_location
#   storage_account_name = var.storage_account_name
#   storage_account_access_key = azurerm_storage_account.function_storage_account.primary_access_key
#   service_plan_id = azurerm_service_plan.function_service_plan.id

#   app_settings = {

#   }
#   site_config  {
#     always_on = false

#   }
# }