locals {
  storage_account_name = "${random_pet.pet.id}${var.storage_account_name}"
  pet_name = random_pet.pet.id
  sas_start_time = timestamp()
  sas_expiry_time = timeadd(local.sas_start_time, "1h")
}