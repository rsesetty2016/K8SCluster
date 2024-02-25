variable "nodes" {
  type = map(any)
  default = {
    "sbb" : {
      "host" : [
        "bastion-test",
        "k8master01-test",
        "k8node01-test",
        "k8node02-test"
      ],
      "host_details" : {
        "bastion-test" : {
          "ip" : "192.168.1.200",
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
          "host_alias": "ansible k8console gitlab"
        },
        "k8master01-test" : {
          "ip" : "192.168.1.210",
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
          "host_alias": "k8master01"

        },
        "k8node01-test" : {
          "ip" : "192.168.1.211",
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
          "host_alias": "k8node01"

        },
        "k8node02-test" : {
          "ip" : "192.168.1.212",
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
          "host_alias": "k8node02"
        }
      }
    }
  }
}
