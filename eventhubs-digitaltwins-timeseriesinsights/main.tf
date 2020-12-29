# Provides client_id, tenant_id, subscription_id and object_id variables
data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.location
}

module "application_insights" {
  source         = "./application_insights"
  basename       = var.appname
  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location
}

module "container_registry" {
  source         = "./container_registry"
  basename       = var.appname
  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location
}

module "simulator" {
  source                    = "./simulator"
  basename                  = "${var.appname}simulator"
  resource_group            = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  eventhub_connectionstring = module.eventhubs_in.send_primary_connection_string
}

module "eventhubs_in" {
  source         = "./eventhubs"
  basename       = "${var.appname}in"
  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location
}

module "function_adt" {
  source              = "./function"
  basename            = "${var.appname}in"
  resource_group      = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  instrumentation_key = module.application_insights.instrumentation_key
  appsettings = {
    ADT_SERVICE_URL = module.digital_twins.service_url
    EVENT_HUB       = module.eventhubs_in.listen_primary_connection_string
  }
}

resource "azurerm_role_assignment" "main" {
  scope                = module.digital_twins.digital_twins_instance_resource_id
  role_definition_name = "Azure Digital Twins Data Owner"
  principal_id         = module.function_adt.system_assigned_identity.principal_id
}

module "digital_twins" {
  source                               = "./digital_twins"
  basename                             = "${var.appname}dt"
  resource_group                       = azurerm_resource_group.main.name
  location                             = azurerm_resource_group.main.location
  eventhub_primary_connection_string   = module.eventhubs_adt.send_primary_connection_string
  eventhub_secondary_connection_string = module.eventhubs_adt.send_secondary_connection_string
  owner_principal_object_id            = data.azurerm_client_config.current.object_id
}

module "eventhubs_adt" {
  source         = "./eventhubs"
  basename       = "${var.appname}dt"
  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location
}

module "function_tsi" {
  source              = "./function"
  basename            = "${var.appname}ts"
  resource_group      = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  instrumentation_key = module.application_insights.instrumentation_key

  appsettings = {
    EVENT_HUB_ADT = module.eventhubs_adt.listen_primary_connection_string
    EVENT_HUB_TSI = module.eventhubs_tsi.send_primary_connection_string
  }
}

module "eventhubs_tsi" {
  source         = "./eventhubs"
  basename       = "${var.appname}ts"
  resource_group = azurerm_resource_group.main.name
  location       = azurerm_resource_group.main.location
}

module "time_series_insights" {
  source                     = "./time_series_insights"
  basename                   = var.appname
  resource_group             = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  reader_principal_object_id = data.azurerm_client_config.current.object_id
  eventhub_namespace_name    = module.eventhubs_tsi.eventhub_namespace_name
  eventhub_name              = module.eventhubs_tsi.eventhub_name
}

module "explorer" {
  source                             = "./digital_twins_explorer"
  basename                           = "${var.appname}explorer"
  resource_group                     = azurerm_resource_group.main.name
  location                           = azurerm_resource_group.main.location
  container_registry_name            = module.container_registry.name
  container_registry_admin_username  = module.container_registry.admin_username
  container_registry_admin_password  = module.container_registry.admin_password
  container_registry_login_server    = module.container_registry.login_server
  container_registry_resource_id     = module.container_registry.resource_id
  instrumentation_key                = module.application_insights.instrumentation_key
  digital_twins_instance_resource_id = module.digital_twins.digital_twins_instance_resource_id
}
