/* output "bastion_instance_id" {
  value = module.bastion_jump_host.instance_id
} */

output "app_role_name" {
  value = module.app_role.role_name
}

output "app_instance_profile_name" {
  value = module.app_role.instance_profile_name
}

output "app_role_arn" {
  value = module.app_role.role_arn
}

output "app_instance_profile_arn" {
  value = module.app_role.instance_profile_arn
}

output "vpc_id" {
  value = module.my_network.vpc_id
}

output "app_sg_id" {
  value = module.app_sg.security_group_id
}
output "private_subnet_ids" {
  value = values(module.my_network.private_subnet_ids)
}