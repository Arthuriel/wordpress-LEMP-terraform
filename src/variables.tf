variable "admin_username" {
  description = "User name to use as the admin account on the VMs that will be part of the VM"
  default     = "devops"
}

variable "admin_password" {
  description = "Default password for admin account"
  default     = ""
}

variable "subscription_id" {
   type    = string
   default = "c2679671-4c32-4129-8310-1a49f35393a1"
 }