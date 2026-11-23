variable "resource_group_name" {
  description = "Existing Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Switzerland North"
}

variable "ddos_plan_name" {
  description = "Azure DDoS Protection Plan name"
  type        = string
}