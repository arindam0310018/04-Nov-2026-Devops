###############################
# Variable Defination:-
###############################

variable "test_subscription_id" {
  description = "Subscription ID containing the existing TEST virtual networks."
  type        = string
}

variable "test_resource_group_name" {
  description = "Resource group containing the existing TEST virtual networks."
  type        = string
}

variable "test_vnet_names" {
  description = "Names of the existing TEST virtual networks to associate with the DDoS plan."
  type        = set(string)
}

variable "prod_subscription_id" {
  description = "Subscription ID containing the existing PROD DDoS protection plan."
  type        = string
}

variable "prod_resource_group_name" {
  description = "Resource group containing the existing PROD DDoS protection plan."
  type        = string
}

variable "ddos_plan_name" {
  description = "Name of the existing DDoS protection plan."
  type        = string
}