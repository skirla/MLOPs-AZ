# terraform/variables.tf

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "centralus"
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "MLPlatform"
    ManagedBy   = "Terraform"
  }
}