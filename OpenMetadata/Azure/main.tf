terraform {
  required_version = ">= 0.12"
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.53.1"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 4.1.0"
    }
    instaclustr = {
      source  = "instaclustr/instaclustr"
      version = "~> 2.0.180"
    }
    external = {
      source = "hashicorp/external"
      version = "~> 2.3.4"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.6.3"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = jsondecode(file(var.sp_creds)).subscriptionId
  client_id       = jsondecode(file(var.sp_creds)).appId
  client_secret   = jsondecode(file(var.sp_creds)).password
  tenant_id       = jsondecode(file(var.sp_creds)).tenant
}

provider "instaclustr" {
  terraform_key = "Instaclustr-Terraform ${jsondecode(file(var.ic_creds)).username}:${jsondecode(file(var.ic_creds)).api_key}"
}

resource "azurerm_resource_group" "om_resource_group" {
  name     = "openmetadata-${terraform.workspace}-rg"
  location = var.azr_region

  tags = {
    environment = "${terraform.workspace}"
    creator     = "${var.creator_tag}"
  }
}
