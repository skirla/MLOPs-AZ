# terraform/backend.tf

terraform {
  backend "azurerm" {
    # These values will be provided during 'terraform init' via CLI args
    # Do NOT hardcode credentials here.
    # resource_group_name  = "Must be supplied by CLI"
    # storage_account_name = "Must be supplied by CLI"
    # container_name       = "Must be supplied by CLI"
    key                  = "prod.terraform.tfstate" # Name of the state file in the container
  }
}