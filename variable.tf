variable "vm_count" {
  description = "Number of VMs to create"
  default     = 3
}

variable "vm_flavor" {
  description = "VM flavor"
  default     = "Standard_B1s"
}

variable "vm_image" {
  description = "VM image"
  default     = "UbuntuLTS"
}
