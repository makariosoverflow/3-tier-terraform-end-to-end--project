variable "vpc_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "frontend-subnet-az1a" {
  type = string
}

variable "key_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "backend-subnet-az1b" {
  type = string
}

variable "backend-subnet-az1a" {
  type = string
}
