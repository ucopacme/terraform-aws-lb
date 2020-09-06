variable "access_logs" {
  default     = {}
  description = "Map of load balancer logging configuration, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#access_logs"
  type        = map(string)
}

variable "drop_invalid_header_fields" {
  default     = false
  description = "remove valid header fields (true) or routed to targets (false)., cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#drop_invalid_header_fields"
  type        = bool
}

variable "enabled" {
  default     = true
  description = "Set to `false` to prevent the module from creating resources"
  type        = bool
}

variable "enable_cross_zone_load_balancing" {
  default     = false
  description = "enable cross-zone load balancing for network load balancer, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#enable_cross_zone_load_balancing"
  type        = bool
}

variable "internal" {
  default     = false
  description = "Set to true to create private load balancer, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#internal"
  type        = bool
}

variable "listeners_http_tcp" {
  description = "A list of maps describing HTTP listeners or TCP ports. Required key/values: port, protocol. Optional key/values: target_group_index (defaults to listeners_http_tcp[count.index])"
  type        = any
  default     = []
}

variable "load_balancer_type" {
  default     = "application"
  description = "type of load balance, application or network, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#load_balancer_type"
  type        = string
}

variable "name" {
  default     = null
  description = "Resource name, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#name"
  type        = string
}

variable "security_groups" {
  default     = null
  description = "list of security group IDs to assign to application LB, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#security_groups"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
  default     = null
}

variable "subnet_mappings" {
  default     = []
  description = "subnet mapping block, cf https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb#subnet_mapping"
  type        = list(map(string))
}

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "target_groups" {
  default     = []
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port"
  type        = any
}

variable "timeout_create" {
  default     = "10m"
  description = "ALB create Timeout"
  type        = string
}

variable "timeout_delete" {
  default     = "10m"
  description = "ALB delete Timeout"
  type        = string
}

variable "timeout_update" {
  default     = "10m"
  description = "ALB update Timeout"
  type        = string
}

variable "vpc_id" {
  default     = null
  description = "VPC id for target group."
  type        = string
}
