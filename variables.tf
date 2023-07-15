variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "testing"
}

variable "resource_group_location" {
  description = "Location to store the resource group meta data"
  default     = "westeurope"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  default     = "mystorage38280"
}

# variable "service_plan_name" {
#   description = "Name of the service plan for the azure function"
#   default = "function_service_plan"
# }

# variable "function_app_name" {
#   description = "Name of the azure function app"
#   default = "myFunction3263"
# }