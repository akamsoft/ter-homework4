variable "name" {
  type        = string
  default     = ""
  description = "VPC name"
}

variable "subnets" {
  type = list(object({
    zone = string,
    cidr = string
  })) 
  description = "Subnets"
}