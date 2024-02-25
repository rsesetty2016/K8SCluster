locals {
     hosts = tolist(var.host_list.host)
     host_contents = ""
    host_details = {
    for h in local.hosts:
        h => { "ip": var.host_list.host_details[h].ip, "alias": var.host_list.host_details[h].host_alias}
    }
}

data "template_file" "cloud_init_config" {
  template = file("${path.module}/../../cloud-init/cloud-config-base")

  vars = {
    ssh_key  = file(var.public_key)
    hostname = var.hostname
    domain   = var.domainname
    nfs_server = var.nfs_server
    nfs_server_mount_path = var.nfs_server_mount_path
    nfs_client_path = var.nfs_client_path
  }
}

# Create a local copy to transfer to Proxmox

resource "local_sensitive_file" "cloud_init_config" {
  content  = data.template_file.cloud_init_config.rendered
  filename = "${path.module}/../../cloud-init/${var.cloud_init_file}_${var.hostname}.yml"
}

resource "null_resource" "cloud_init_config" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key)
    host        = var.proxmox_host_ip
  }

  provisioner "file" {
    source      = local_sensitive_file.cloud_init_config.filename
    destination = "/var/lib/vz/snippets/cloud_init_${var.hostname}.yml"
  }
}

output "host_created" {
  value = "${var.hostname} was created."
}


output "cloud_init_file" {
  value = "cloud_init_${var.hostname}.yml"
}



resource "proxmox_vm_qemu" "new_node" {

    depends_on = [
        null_resource.cloud_init_config
    ]

      name        = var.hostname
      desc        = var.host_description
      target_node = var.proxmox_node_name
      

      clone = var.os_image

      agent = 1
      onboot = true
      #kvm = false

      cpu = "host"

      disk {
        slot = var.disk_slot
        # set disk size here. leave it small for testing because expanding the disk takes time.
        size = var.disk_size
        type = var.disk_type
        storage = var.storage
        iothread = 0
      }

      cores   = var.cores
      sockets = var.sockets
      memory  = var.memory
      network {
        model = var.network_model
        bridge = var.network_bridge
      }

      os_type   = var.os_type
      cicustom = "user=local:snippets/cloud_init_${var.hostname}.yml"
      
      ipconfig0 = "ip=${var.ip_address}/24,gw=${var.gateway}"

      lifecycle {
        ignore_changes = [
            network
        ]
      }

}    

resource "local_file" "etc_hosts" {
  filename = "${path.module}/../bastion/initial_repo/${terraform.workspace}_hosts.txt"
  content = <<-EOT
    %{ for h in local.hosts ~}
    ${local.host_details[h].ip}  ${local.host_details[h].alias} 
    %{ endfor ~}
    EOT
}


resource "null_resource" "copy_hosts_file" {


    depends_on = [
        proxmox_vm_qemu.new_node, local_file.etc_hosts
    ]
  
  provisioner "file" {
    source = "${path.module}/../bastion/initial_repo/${terraform.workspace}_hosts.txt"
    destination = "/tmp/hosts.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo sh -c 'cat /tmp/hosts.txt >> /etc/hosts'",
      "sudo rm /tmp/hosts.txt"
    ]
  }
  
 connection {
        type = "ssh"
        user = "proxuser"
        private_key = file(var.private_key)
        host = var.ip_address
  }
}