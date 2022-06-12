locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  secret_vars      = read_terragrunt_config(find_in_parent_folders("secret_values.hcl"))

  s3_region = local.environment_vars.locals.s3_region
  yc_zone   = local.environment_vars.locals.zone
  yc_folder_id   = local.environment_vars.locals.folder_id
  yc_cloud_id = local.environment_vars.locals.yc_cloud_id

  yc_token    = local.secret_vars.locals.yc_token
  s3_access_key = local.secret_vars.locals.s3_access_key
  s3_secret_key = local.secret_vars.locals.s3_secret_key
  s3_bucket     = local.secret_vars.locals.s3_bucket
}

generate "provider" {
  path      = "provider_gen.tf"
  if_exists = "overwrite"
  contents = templatefile("${get_parent_terragrunt_dir()}/provider.tmpl", {
    bucket         = local.s3_bucket
    
    s3_path        = "${path_relative_to_include()}/terraform.tfstate"
    s3_region = local.s3_region

    cloud_id = local.yc_cloud_id
    folder_id      = local.yc_folder_id
    zone           = local.yc_zone

    access_key  = local.s3_access_key
    secret_key  = local.s3_secret_key
    token       = local.yc_token

  })
}


inputs = merge(
  local.environment_vars.locals,
)
