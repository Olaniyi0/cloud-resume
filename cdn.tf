resource "azurerm_cdn_profile" "resume_cdn_profile" {
  depends_on = [ azurerm_resource_group.cloud_resume_rg ]
  name                = "${local.storage_account_name}-cdn-profile"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "resume_cdn_endpoint" {
  depends_on = [ azurerm_cdn_profile.resume_cdn_profile ]
  name                = local.storage_account_name
  profile_name        = azurerm_cdn_profile.resume_cdn_profile.name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  origin_host_header = "${local.storage_account_name}.z6.web.core.windows.net"

  origin {
    name      = local.storage_account_name
    host_name = "${local.storage_account_name}.z6.web.core.windows.net"
  }
}

data "azurerm_dns_zone" "myresumes" {
  name = "myresumes.live"
  resource_group_name = "cloud-resume-challenge"
}

resource "azurerm_dns_cname_record" "myresumes" {
  name = "test"
  zone_name = data.azurerm_dns_zone.myresumes.name
  resource_group_name = data.azurerm_dns_zone.myresumes.resource_group_name
  ttl = 3600
  record = azurerm_cdn_endpoint.resume_cdn_endpoint.fqdn
}

resource "azurerm_cdn_endpoint_custom_domain" "myresumes" {
  name = "myresumes-domain"
  cdn_endpoint_id = azurerm_cdn_endpoint.resume_cdn_endpoint.id
  host_name = "${azurerm_dns_cname_record.myresumes.name}.${data.azurerm_dns_zone.myresumes.name}"
  cdn_managed_https {
    certificate_type = "Dedicated"
    protocol_type = "ServerNameIndication"
    tls_version = "TLS12"
  }
}