# terraform/main.tf (or providers.tf)

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Use a recent, pinned version
    }
  }
}


provider "azurerm" {
  features {}

  # Authentication is handled by environment variables set by the
  # azure/login action when using OIDC or Service Principal.
  # No need to specify subscription_id, client_id, etc. here.
  use_oidc = true # Explicitly tell the provider to try OIDC
}

# --- Your ML Infrastructure Resources Go Below ---

resource "azurerm_resource_group" "ml_rg" {
  name     = "ml-${var.environment}-rg" # Example using variables
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "ml_storage" {
  name                     = "mlsa${var.environment}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.ml_rg.name
  location                 = azurerm_resource_group.ml_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_key_vault" "ml_kv" {
   name                        = "mlkv-${var.environment}-${random_id.suffix.hex}"
   location                    = azurerm_resource_group.ml_rg.location
   resource_group_name         = azurerm_resource_group.ml_rg.name
   tenant_id                   = data.azurerm_client_config.current.tenant_id # Get tenant ID dynamically
   sku_name                    = "standard"
   soft_delete_retention_days  = 7
   purge_protection_enabled    = false # Set to true for production
   tags                        = var.tags
}

resource "azurerm_application_insights" "ml_appinsights" {
   name                = "mlai-${var.environment}-${random_id.suffix.hex}"
   location            = azurerm_resource_group.ml_rg.location
   resource_group_name = azurerm_resource_group.ml_rg.name
   application_type    = "web"
   tags                = var.tags
}

resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                          = "mlw-${var.environment}-${random_id.suffix.hex}"
  location                      = azurerm_resource_group.ml_rg.location
  resource_group_name           = azurerm_resource_group.ml_rg.name
  application_insights_id       = azurerm_application_insights.ml_appinsights.id
  key_vault_id                  = azurerm_key_vault.ml_kv.id
  storage_account_id            = azurerm_storage_account.ml_storage.id
  identity {
    type = "SystemAssigned"
  }
  tags = var.tags

  depends_on = [
    azurerm_storage_account.ml_storage,
    azurerm_key_vault.ml_kv,
    azurerm_application_insights.ml_appinsights
  ]
}

# Helper to get current tenant ID for Key Vault
data "azurerm_client_config" "current" {}

# Helper for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}