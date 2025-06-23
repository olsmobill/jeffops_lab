variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "The name of the EC2 key pair to use"
  type        = string
}
