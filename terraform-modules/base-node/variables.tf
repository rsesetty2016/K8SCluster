variable "domainname" {
  type    = string
  default = ""
}

variable "public_key" {
  type    = string
  default = ""
}


variable "private_key" {
  type    = string
  default = ""
}

variable "cloud_init_file" {
  type    = string
  default = ""
}


variable "proxmox_host_ip" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = ""
}

variable "proxmox_node_name" {
  type    = string
  default = ""
}

variable "host_description" {
  type    = string
  default = ""
}

variable "os_image" {
  type    = string
  default = ""
}

variable "disk_slot" {
    type    = string
    default = 0
} 
variable "disk_size" {
    type    = string
    default = "50G"
} 
variable "disk_type" {
    type    = string
    default = "scsi"
} 

variable "storage" {
    type    = string
    default = "local-lvm"
} 

variable "cores" {
type    = number
  default =  4
}
variable "sockets" {
    type    = number
  default =  1
}
variable "memory" {
    type    = number
  default =  8192
}
variable "network_model" {
    type    = string
    default =  "virtio"
}
variable "network_bridge" {
    type = string
    default =  "vmbr0"
  }

variable "os_type" {
    type = string
  default =  "cloud-init"
}
variable "gateway" {
 type = string
 default = ""
}

variable "ip_address" {
    type = string
    default = ""
}

variable "host_list" {}

variable nfs_server {}

variable nfs_server_mount_path {}

variable nfs_client_path {}