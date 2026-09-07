output "instance_public_ip" {
  description = "Public IP of the app server - use this for the Ansible inventory"
  value       = aws_instance.app_server.public_ip
}

output "ssh_command" {
  value = "ssh -i <path-to-your-key>.pem ec2-user@${aws_instance.app_server.public_ip}"
}
