output "mysg_id" {
  value = aws_security_group.mysg.id
}

output "launch_sg" {
  value = aws_security_group.launchsg.id
  
}
output "db_id" {
  value = aws_security_group.db_sg.id
}
