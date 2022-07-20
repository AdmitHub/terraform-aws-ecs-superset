output "app_service_security_group_id" {
  value = module.app_ecs.ecs_service_security_group_id
}

output "target_group_suffix" {
  value = aws_alb_target_group.superset.arn_suffix
}
