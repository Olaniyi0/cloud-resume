output "website_endpoint" {
  value = azurerm_storage_account.resume_storage_account.primary_web_endpoint
}

output "cdn_endpoint_fqdn" {
  value = azurerm_cdn_endpoint.resume_cdn_endpoint.fqdn
}

output "custom_domain_name_id" {
  value = azurerm_cdn_endpoint_custom_domain.myresumes.id
}