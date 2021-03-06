locals {
  build             = abspath("${path.module}/target")
  function_zip_name = "functionapp-${sha1(var.source_path)}-${data.archive_file.source_code.output_sha}.zip"
}

resource "azurerm_storage_account" "main" {
  name                     = "st${var.basename}"
  location                 = var.location
  resource_group_name      = var.resource_group
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "main" {
  name                = "plan-${var.basename}"
  location            = var.location
  resource_group_name = var.resource_group
  kind                = lower(var.tier) == "dynamic" ? "FunctionApp" : "elastic" 
  reserved            = true

  sku {
    tier     = var.tier
    size     = var.sku
    capacity = var.workers
  }
}

# Build a ZIP file for the sole purpose of detecting changes in the source directory and triggering recompilation and upload.
# The ZIP file is not otherwise used.
# https://stackoverflow.com/questions/51138667/can-terraform-watch-a-directory-for-changes
data "archive_file" "source_code" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${local.build}/data-${sha1(var.source_path)}.zip"
  excludes    = ["bin", "obj", "local.settings.json"]
}

resource "null_resource" "functionapp" {
  triggers = {
    src_hash = local.function_zip_name
  }

  provisioner "local-exec" {
    command     = <<-EOT
      dotnet publish --configuration ${var.configuration}
      cd bin/${var.configuration}/*/publish
      mkdir -p ${local.build}
      zip -r -X ${local.build}/${local.function_zip_name} *
      EOT
    interpreter = ["bash", "-cex"]
    working_dir = var.source_path
  }
}

resource "azurerm_function_app" "main" {
  name                       = "func-${var.basename}"
  location                   = var.location
  resource_group_name        = var.resource_group
  app_service_plan_id        = azurerm_app_service_plan.main.id
  storage_account_name       = azurerm_storage_account.main.name
  storage_account_access_key = azurerm_storage_account.main.primary_access_key
  https_only                 = true
  version                    = "~3"
  os_type                    = "linux"
  app_settings = merge({
    WEBSITE_RUN_FROM_PACKAGE       = "https://${azurerm_storage_account.main.name}.blob.core.windows.net/${azurerm_storage_container.funcdeploy.name}/${azurerm_storage_blob.functionzip.name}${data.azurerm_storage_account_sas.funcdeploy.sas}"
    FUNCTIONS_WORKER_RUNTIME       = "dotnet"
    APPINSIGHTS_INSTRUMENTATIONKEY = var.instrumentation_key
  }, var.appsettings)
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "funcdeploy" {
  name                  = "func-deploy"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "functionzip" {
  name                   = local.function_zip_name
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.funcdeploy.name
  type                   = "Block"
  source                 = "${local.build}/${local.function_zip_name}"
  depends_on = [
    null_resource.functionapp,
  ]
}

data "azurerm_storage_account_sas" "funcdeploy" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = false
  resource_types {
    service   = false
    container = false
    object    = true
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start  = "2018-03-21"
  expiry = "2028-03-21"
  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}
