variable "domainname" {
  type = map(any)
  default = {
    "sbb" : "int.vaanj.com"
    "test" : "test.com"
  }
}

variable "tls_kube_key" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/k8s-api-key.pem",
    "kpcs" : "~/.ssh/id_proxmox.pub"
  }
}

variable "tls_kube_cert" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/k8s-api-cert.pem",
    "kpcs" : "~/.ssh/id_proxmox.pub"
  }
}

variable "tls_kube_ca_cert" {
  type = map(any)
  default = {
    "sbb" : "~/.ssh/ca-cert.pem",
    "kpcs" : "~/.ssh/id_proxmox.pub"
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

variable "k8_control_ip" {
  type = map(any)
  default = {
    "sbb" : "192.168.1.110"
  }
}


variable "nodes" {
  type = map(any)
  default = {
    "sbb" : {
      "host" : [
        "bastion",
        "k8master01",
        "k8node01",
        "k8node02",
        "k8node03"
      ],
      "host_details" : {
        "bastion" : {
          "ip" : "192.168.1.100",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "HA Proxy Host",
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
        },
        "k8master01" : {
          "ip" : "192.168.1.110",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "K8S Control node"
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
          "host_type" : "control",
          "host_alias" : "k8master01"

        },
        "k8node01" : {
          "ip" : "192.168.1.111",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "K8S Worker node"
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
          "host_type" : "worker",
          "host_alias" : "k8node01"

        },
        "k8node02" : {
          "ip" : "192.168.1.112",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "K8S Worker node"
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
          "host_type" : "worker",
          "host_alias" : "k8node02"
        },
        "k8node03" : {
          "ip" : "192.168.1.113",
          "os_image" : "ubuntu-2204-cloudinit-template",
          "description" : "K8S Worker node"
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
          "host_type" : "worker",
          "host_alias" : "k8node03"
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

# Ansible - Begin

variable ansible_host {
  type = map
  default = {
    "sbb": "192.168.1.100",
    "kpcs": ""
  }
}
variable "ansible_home_directory" {
  type = map(any)
  default = {
    "sbb" : "/projects/ansible",
    "kpcs" : "/projects/ansible"
  }

}

variable "ansible_secret_path" {
  type    = string
  default = "/var/lib/secure/ansible"
}

variable "ansible_secret_file" {
  type    = string
  default = "/var/lib/secure/ansible/.ansible.pw"
}

variable "ansible_user" {
  type = map(any)
  default = {
    "sbb" : "svc_ansible",
    "kpcs" : "svc_ansible"
  }
}

variable "ansible_pwd" {
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

# Ansible - End

variable "ha_entry_ip" {
  type = map(any)
  default = {
    "sbb" : "192.168.1.100"
  }
}

variable k8_kubelet_version {
  type = string
  default = "1.28.2-00"
}

variable k8_kubeadm_version {
  type = string
  default = "1.28.2-00"
}

variable k8_kubectl_version {
  type = string
  default = "1.28.2-00"
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

variable ceph_key {
  type = string
}

variable ceph_server {
  type = map
  default = {
    "sbb": {
      "monitors": "[192.168.1.47:6789]", ### Note that it is string but will be created as a list when a configuration file is generated.
      "name": "ceph-pv",
      "storage": "100Gi",
      "accessModes": "[ReadWriteMany]",
      "pool": "pv_data",
      "image": "cephfs",
      "user": "admin", 
      "secret": "ceph-key-secret",
      "fsType": "ext4",
      "readOnly": "false"
    },
    "kpcs": {
      "monitors": "[192.168.1.136:6789,192.168.1.133:6789,192.168.1.115:6789]", ### Note that it is string but will be created as a list when a configuration file is generated.
      "name": "NVME_CEPH",
      "storage": "100Gi",
      "accessModes": "[ReadWriteMany]",
      "pool": "NVME_CEPH_DATA",
      "image": "cephfs",
      "user": "admin", 
      "secret": "ceph-key-secret",
      "fsType": "ext4",
      "readOnly": "false"
    }
  }
}


