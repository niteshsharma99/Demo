variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "instance_ami" {
  description = "AMI ID"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
}

