variable "key_name" {
  description = "Name of an existing EC2 key pair (created in AWS console) used for SSH access"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form, e.g. 123.45.67.89/32 (restricts SSH access to just you)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # free-tier eligible
}
