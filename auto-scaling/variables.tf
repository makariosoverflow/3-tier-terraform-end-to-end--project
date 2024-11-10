variable "vpc_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}
variable "alb_sg_id" {
  type = string
}

variable "frontend-subnet-az1a" {
  type = string
}

variable "frontend-subnet-az1b" {
  type = string
}
variable "target_group_arn" {
  type = list(string)
}