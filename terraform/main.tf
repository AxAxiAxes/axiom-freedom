terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID."
}

variable "client_id" {
  type        = string
  description = "Azure service principal/client ID."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Azure service principal secret."
}

variable "location" {
  type        = string
  description = "Azure region for deployment."
  default     = "eastus"
}

variable "name_prefix" {
  type        = string
  description = "Resource naming prefix (must be globally unique for storage/SWA)."
  default     = "axiomfreedom"
}

variable "create_dns_zone" {
  type        = bool
  description = "When true, create DNS zone and CNAME records in Azure DNS."
  default     = false
}

variable "custom_domain" {
  type        = string
  description = "Custom domain (e.g. axiom.com). Leave empty to skip custom domain binding."
  default     = ""
}

locals {
  trimmed_domain = trimspace(var.custom_domain)
}

resource "azurerm_resource_group" "axiom" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "axiom" {
  name                = "${var.name_prefix}-law"
  location            = azurerm_resource_group.axiom.location
  resource_group_name = azurerm_resource_group.axiom.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "axiom" {
  name                = "${var.name_prefix}-appi"
  location            = azurerm_resource_group.axiom.location
  resource_group_name = azurerm_resource_group.axiom.name
  workspace_id        = azurerm_log_analytics_workspace.axiom.id
  application_type    = "web"
}

resource "azurerm_storage_account" "logs" {
  name                     = substr(replace("${var.name_prefix}logs", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.axiom.name
  location                 = azurerm_resource_group.axiom.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "session_logs" {
  name                  = "session-logs"
  storage_account_name  = azurerm_storage_account.logs.name
  container_access_type = "private"
}

resource "azurerm_static_web_app" "axiom" {
  name                = "${var.name_prefix}-swa"
  resource_group_name = azurerm_resource_group.axiom.name
  location            = azurerm_resource_group.axiom.location
  sku_tier            = "Standard"
  sku_size            = "Standard"
}

resource "azurerm_monitor_diagnostic_setting" "swa_diagnostics" {
  name                       = "${var.name_prefix}-swa-diag"
  target_resource_id         = azurerm_static_web_app.axiom.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.axiom.id

  enabled_log {
    category = "StaticSitesConsoleLogs"
  }

  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
  name                       = "${var.name_prefix}-storage-diag"
  target_resource_id         = "${azurerm_storage_account.logs.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.axiom.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
  }
}

resource "azurerm_dns_zone" "axiom" {
  count               = var.create_dns_zone && local.trimmed_domain != "" ? 1 : 0
  name                = local.trimmed_domain
  resource_group_name = azurerm_resource_group.axiom.name
}

resource "azurerm_dns_cname_record" "www" {
  count               = var.create_dns_zone && local.trimmed_domain != "" ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.axiom[0].name
  resource_group_name = azurerm_resource_group.axiom.name
  ttl                 = 300
  record              = azurerm_static_web_app.axiom.default_host_name
}

resource "azurerm_dns_cname_record" "chat" {
  count               = var.create_dns_zone && local.trimmed_domain != "" ? 1 : 0
  name                = "chat"
  zone_name           = azurerm_dns_zone.axiom[0].name
  resource_group_name = azurerm_resource_group.axiom.name
  ttl                 = 300
  record              = azurerm_static_web_app.axiom.default_host_name
}

resource "azurerm_static_web_app_custom_domain" "www" {
  count             = local.trimmed_domain != "" ? 1 : 0
  static_web_app_id = azurerm_static_web_app.axiom.id
  domain_name       = "www.${local.trimmed_domain}"
  validation_type   = "cname-delegation"
}

output "resource_group_name" {
  value = azurerm_resource_group.axiom.name
}

output "static_web_default_hostname" {
  value = azurerm_static_web_app.axiom.default_host_name
}

output "static_web_app_deployment_token" {
  value     = azurerm_static_web_app.axiom.api_key
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.logs.name
}

output "application_insights_connection_string" {
  value     = azurerm_application_insights.axiom.connection_string
  sensitive = true
}
