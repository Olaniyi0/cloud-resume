locals {
  storage_account_name = "${random_pet.pet.id}${var.storage_account_name}"
}