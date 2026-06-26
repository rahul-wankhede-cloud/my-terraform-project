output "instance_ids" {
  value = values(aws_instance.this)[*].id
}