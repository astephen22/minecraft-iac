variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
}

variable "my_ip" {
  description = "Your public IP with /32"
}
