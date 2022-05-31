variable "admin_username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM"
  default     = "devops"
}

# variable "admin_password" {
#   description = "Default password for admin account"
#   default     = ""
# }

variable "subscription_id" {
  type    = string
  default = "e4698f64-76c2-45f6-8e37-3582776fd222"
}