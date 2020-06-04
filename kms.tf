resource "aws_kms_key" "apiary_kms" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  description = "apiary ${each.key} kms key"
  policy      = data.template_file.vault_kms_key_policy[each.key].rendered

  lifecycle {
    prevent_destroy = true
  }
}

data "template_file" "apiary_kms_key_policy" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if schema["encryption"] == "aws:kms"
  }

  template = file("${path.module}/templates/apiary_kms_key_policy.json")

  vars = {
    aws_region   = data.aws_region.current.name
    aws_account  = data.aws_caller_identity.current.account_id
    admin_roles  = replace(schema["admin_roles"], ",", "\",\"")
    client_roles = ""
  }
}
