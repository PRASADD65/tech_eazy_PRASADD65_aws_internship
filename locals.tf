locals {
  config_file_map = {
    dev  = "dev_config.json"
    prod = "prod_config.json"
  }

  config_file = lookup(local.config_file_map, lower(var.stage), "dev_config.json")
}
#This maps stage like "Dev" or "Prod" to the correct config file, with "dev" as fallback.
