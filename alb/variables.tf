variable "vpc_id" {
  type = string
}
variable "frontend-subnet-az1a" {
  type = string
}

variable "frontend-subnet-az1b" {
  type = string
}

variable "tags" {
  type = map(string)
}


variable "certificate_arn" {
  type = string
}

variable "ssl_policy" {
  type = string
}
