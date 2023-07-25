resource "azurerm_service_plan" "myresume-plan" {
  depends_on = [ azurerm_resource_group.cloud_resume_rg ]
  name = "${local.pet_name}-service-plan"
  location = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type = "Linux"
  sku_name = "Y1"
}

resource "azurerm_linux_function_app" "myresume_linux_func_app" {
  depends_on = [ azurerm_service_plan.myresume-plan ]
  name = "${local.pet_name}-linux-func-app"
  resource_group_name = var.resource_group_name
  location = var.resource_group_location
  storage_account_name = local.storage_account_name
  storage_account_access_key = azurerm_storage_account.resume_storage_account.primary_access_key
  service_plan_id = azurerm_service_plan.myresume-plan.id

  site_config {
    cors {
      allowed_origins = ["https://${azurerm_dns_cname_record.myresumes.name}.${data.azurerm_dns_zone.myresumes.name}"]
    }
    application_stack {
      python_version = "3.10"
    }
  }
  app_settings = {
    "RESUMEDB_CONNECTION_STRING": "${azurerm_cosmosdb_account.resume-db.connection_strings[0]}",
    "WEBSITE_RUN_FROM_PACKAGE": "${azurerm_storage_blob.function_blob.url}${data.azurerm_storage_account_sas.function_app_blob_sas.sas}"
  }
  
}

# resource "azurerm_function_app_function" "myresumes_app_func" {
#   name = "${local.pet_name}-app-func"
#   function_app_id = azurerm_linux_function_app.myresume_linux_func_app.id
#   language = "Python"
#   file {
#     name = "__init__.py"
#     content = file("../myfunc/HttpTrigger1/__init__.py")
#   }
#   config_json = jsondecode({
#     "bindings": [
#     {
#       "authLevel": "anonymous",
#       "type": "httpTrigger",
#       "direction": "in",
#       "name": "req",
#       "methods": [
#         "get",
#         "post"
#       ]
#     },
#     {
#       "name": "messageJSON",
#       "type": "table",
#       "tableName": "visitors",
#       "partitionKey": "VisitorsCount",
#       "rowKey": "1",
#       "connection": "RESUMEDB_CONNECTION_STRING",
#       "direction": "in"
#     },
#     {
#       "type": "http",
#       "direction": "out",
#       "name": "$return"
#     }
#   ]
#   })

# }