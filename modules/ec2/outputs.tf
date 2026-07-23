output "instance_ids" { value = aws_instance.web[*].id }
output "security_group_id" { value = aws_security_group.web_sg.id }
