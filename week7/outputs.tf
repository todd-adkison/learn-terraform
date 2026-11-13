output "rg_data_name" {
  value = module.rg_data.name
}

output "storage_account_name" {
  value = module.storage.name
}

output "storage_blob_endpoint" {
  value = module.storage.primary_blob_endpoint
}
