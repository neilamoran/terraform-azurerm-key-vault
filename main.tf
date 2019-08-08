data "azuread_group" "main" {
  count = length(local.group_names)
  name  = local.group_names[count.index]
}

data "azuread_user" "main" {
  count               = length(local.user_principal_names)
  user_principal_name = local.user_principal_names[count.index]
}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_client_config" "main" {}

resource "azurerm_key_vault" "main" {
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.main.tenant_id

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  sku_name = var.sku

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "main" {
  count        = length(local.combined_access_policies)
  key_vault_id = azurerm_key_vault.main.id

  tenant_id = data.azurerm_client_config.main.tenant_id
  object_id = local.combined_access_policies[count.index].object_id

  certificate_permissions = local.combined_access_policies[count.index].certificate_permissions
  key_permissions         = local.combined_access_policies[count.index].key_permissions
  secret_permissions      = local.combined_access_policies[count.index].secret_permissions
  storage_permissions     = local.combined_access_policies[count.index].storage_permissions
}

resource "azurerm_key_vault_secret" "main" {
  count        = length(var.secrets)
  name         = var.secrets[count.index].name
  value        = var.secrets[count.index].value
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_access_policy.main]
}

resource "azurerm_key_vault_access_policy" "self" {
  count        = local.service_principal_object_id != "" ? 1 : 0
  key_vault_id = azurerm_key_vault.main.id

  tenant_id = data.azurerm_client_config.main.tenant_id
  object_id = local.service_principal_object_id

  key_permissions    = ["create", "delete", "get"]
  secret_permissions = ["delete", "get", "set"]
}
