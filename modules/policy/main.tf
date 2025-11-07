data "azurerm_client_config" "current" {}

# Policy Definition - Require Tags
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require specific tags on resources"
  description  = "This policy requires specific tags on resources"

  metadata = jsonencode({
    category = "Tags"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['Environment']"
          exists = "false"
        },
        {
          field  = "tags['Owner']"
          exists = "false"
        },
        {
          field  = "tags['Project']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition - Allowed Locations
resource "azurerm_policy_definition" "allowed_locations" {
  name         = "allowed-locations"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Allowed locations for resources"
  description  = "This policy restricts the locations where resources can be deployed"

  metadata = jsonencode({
    category = "General"
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "The list of allowed locations for resources"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      not = {
        field = "location"
        in    = "[parameters('allowedLocations')]"
      }
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Definition - Require Encryption
resource "azurerm_policy_definition" "require_encryption" {
  name         = "require-storage-encryption"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require encryption for storage accounts"
  description  = "This policy requires encryption for storage accounts"

  metadata = jsonencode({
    category = "Storage"
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field  = "Microsoft.Storage/storageAccounts/enableHttpsTrafficOnly"
          notEquals = "true"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

# Policy Assignment - Require Tags
resource "azurerm_management_group_policy_assignment" "require_tags" {
  name                 = "require-tags"
  management_group_id  = var.management_group_id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  display_name         = "Require Tags on Resources"
  description          = "Enforces required tags on all resources"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }
}

# Policy Assignment - Allowed Locations
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  management_group_id  = var.management_group_id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id
  display_name         = "Allowed Locations"
  description          = "Restricts resource deployment to allowed locations"
  location             = var.location

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })

  identity {
    type = "SystemAssigned"
  }
}

# Policy Assignment - Built-in: Deploy Azure Security Center
resource "azurerm_management_group_policy_assignment" "deploy_asc" {
  name                 = "deploy-asc"
  management_group_id  = var.management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/ac076320-ddcf-4066-b451-6154267e8ad2"
  display_name         = "Deploy Azure Security Center"
  description          = "Deploys Azure Security Center on subscriptions"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }
}

# Policy Assignment - Built-in: Deploy Diagnostic Settings
resource "azurerm_management_group_policy_assignment" "deploy_diagnostics" {
  name                 = "deploy-diagnostics"
  management_group_id  = var.management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/0884adba-2312-4468-abeb-5422caed1038"
  display_name         = "Deploy Diagnostic Settings"
  description          = "Deploys diagnostic settings for Azure resources"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }
}

# Policy Initiative (Policy Set) - Security Baseline
resource "azurerm_policy_set_definition" "security_baseline" {
  name         = "security-baseline"
  policy_type  = "Custom"
  display_name = "Security Baseline"
  description  = "Security baseline policies for the organization"

  metadata = jsonencode({
    category = "Security"
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
    reference_id         = "requireTags"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_encryption.id
    reference_id         = "requireEncryption"
  }

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c"
    reference_id         = "storageAccountsShouldRestrictNetworkAccess"
  }
}

# Policy Assignment - Security Baseline
resource "azurerm_management_group_policy_assignment" "security_baseline" {
  name                 = "security-baseline"
  management_group_id  = var.management_group_id
  policy_definition_id = azurerm_policy_set_definition.security_baseline.id
  display_name         = "Security Baseline Initiative"
  description          = "Applies security baseline policies"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }
}
