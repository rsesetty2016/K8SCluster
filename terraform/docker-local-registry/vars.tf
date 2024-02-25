variable "domainname" {
  type = map(any)
  default = {
    "sbb" : "int.vaanj.com"
    "test" : "test.com"
  }
}

variable "ssh_private_key_local_host" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/id_rsa",
    "kpcs" : "~/.ssh/id_proxmox"
  }
}

variable "ssh_public_key_local_host" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/id_rsa.pub",
    "kpcs" : "~/.ssh/id_proxmox.pub"
  }
}

variable "cloud_init_file" {
  type = map(any)
  default = {
    "sbb" : "cloud-config-base"
    "test" : "test-cloud-base"
  }
}

variable "proxmox_node" {
  type = map(any)
  default = {
    "sbb" : "master-pve",
    "kpcs" : "pve2022"
  }
}


variable "proxmox_host_ip" {
  type = map(any)
  default = {
    "sbb" : "192.168.1.47"
  }
}


variable "nodes" {
  type = map(any)
  default = {
    "sbb" : {
      "host" : [
        "local-docker"
      ],
      "host_details" : {
        "local-docker" : {
          "ip" : "192.168.1.120",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "Local Docker Host",
          "disk_slot" : "0",
          "disk_size" : "50G",
          "disk_type" : "scsi",
          "storage" : "local-lvm",
          "cores" : 4,
          "sockets" : 1,
          "memory" : 8192,
          "network_model" : "virtio",
          "network_bridge" : "vmbr0",
          "os_type" : "cloud-init",
          "gateway" : "192.168.1.1",
          "host_type" : "bastion",
          "host_alias" : "ansible k8console gitlab"
        }
      }
    }
  }
}


variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type = string
}

variable "pm_api_token_secret" {
  type = string
}

variable "ssh_ansible_public_key" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/id_proxmox_svc_ansible.pub",
    "kpcs" : "~/.ssh/id_proxmox.pub"
  }
}

variable "ssh_ansible_private_key" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/id_proxmox_svc_ansible",
    "kpcs" : "~/.ssh/id_proxmox"
  }
}

variable "ha_entry_ip" {
  type = map(any)
  default = {
    "sbb" : "192.168.1.100"
  }
}

variable nfs_server {
  type = map
  default = {
    "sbb": {
      "server": "192.168.1.47",
      "mount_point": "/DATA-ZFS-1/kubernetes",
      "size": "250Gi"
    }, 
    "kpcs": {
      "server": "",
      "mount_point": ""
    }
  }
}

variable nfs_client_path {
  type = map
  default = {
    "sbb": "/nfs/kubernetes",
    "kpcs": "/nfs/kubernetes"
  }
}
