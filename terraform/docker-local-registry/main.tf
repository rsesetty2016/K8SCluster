locals {
  ws                  = terraform.workspace
  proxmox_host_ip     = lookup(var.proxmox_host_ip, terraform.workspace)
  nodes               = lookup(var.nodes, terraform.workspace)
  cloud_init_file     = lookup(var.cloud_init_file, terraform.workspace)
  domainname          = lookup(var.domainname, terraform.workspace)
  private_key         = lookup(var.ssh_private_key_local_host, terraform.workspace)
  public_key          = lookup(var.ssh_public_key_local_host, terraform.workspace)
  proxmox_node_name   = lookup(var.proxmox_node, terraform.workspace)
  node_count          = length(lookup(var.nodes, terraform.workspace).host)
  ansible_private_key = lookup(var.ssh_ansible_private_key, terraform.workspace)
  ansible_public_key  = lookup(var.ssh_ansible_public_key, terraform.workspace)
  ha_entry_ip         = lookup(var.ha_entry_ip, terraform.workspace)
  nfs_server_ip = lookup(var.nfs_server, terraform.workspace).server
  nfs_server_mount_path = lookup(var.nfs_server, terraform.workspace).mount_point
  nfs_client_path = lookup(var.nfs_client_path, terraform.workspace)
  nfs_storage_size = lookup(var.nfs_server, terraform.workspace).size
}

module "node" {
  count = 1
  source = "../../terraform-modules/base-node"
  proxmox_host_ip   = local.proxmox_host_ip
  hostname          = local.nodes.host[count.index]
  cloud_init_file   = local.cloud_init_file
  domainname        = local.domainname
  private_key       = local.private_key
  public_key        = local.public_key
  proxmox_node_name = local.proxmox_node_name
  host_description  = local.nodes.host_details[local.nodes.host[count.index]].description
  os_image          = local.nodes.host_details[local.nodes.host[count.index]].os_image
  disk_slot         = local.nodes.host_details[local.nodes.host[count.index]].disk_slot
  disk_size         = local.nodes.host_details[local.nodes.host[count.index]].disk_size
  disk_type         = local.nodes.host_details[local.nodes.host[count.index]].disk_type
  storage           = local.nodes.host_details[local.nodes.host[count.index]].storage
  cores             = local.nodes.host_details[local.nodes.host[count.index]].cores
  sockets           = local.nodes.host_details[local.nodes.host[count.index]].sockets
  memory            = local.nodes.host_details[local.nodes.host[count.index]].memory
  network_model     = local.nodes.host_details[local.nodes.host[count.index]].network_model
  network_bridge    = local.nodes.host_details[local.nodes.host[count.index]].network_bridge
  os_type           = local.nodes.host_details[local.nodes.host[count.index]].os_type
  gateway           = local.nodes.host_details[local.nodes.host[count.index]].gateway
  ip_address        = local.nodes.host_details[local.nodes.host[count.index]].ip
  host_list         = local.nodes
  nfs_server = local.nfs_server_ip
  nfs_server_mount_path = local.nfs_server_mount_path
  nfs_client_path = local.nfs_client_path
}

resource "null_resource" "files_to_copy" {
  connection {
        type = "ssh"
        user = "${var.ansible_user}"
        private_key = file(var.private_key)
        host = var.ip_address
  }

  provisioner "file" {
    source = "${path.module}/files"
    destination = "/tmp"
  }
}

resource "null_resource" "copy_docker_files" {

    depends_on          = [module.node]
    provisioner "remote-exec" {
        inline = [
        "cloud-init status --wait",
        "sudo apt install -y docker-compose",
        "sudo apt install -y nginx", 
        "mkdir -p ~/docker-registry/data",
        "mkdir ~/docker-registry/auth",
        "htpasswd -Bbc ~/docker-registry/auth/registry.password docker-user testpw123",
        "sudo usermod -aG docker svc_ansible",
        "sudo cp /tmp/default /etc/nginx/sites-available/default",
        "sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf",
        "cp /tmp/docker-compose.yml ~/docker-registry/.",
        "sudo snap install --classic certbot", 
        "sudo ln -s /snap/bin/certbot /usr/bin/certbot",
        "sudo certbot --nginx -d docker.vaanj.com" # This has been not tested, make sure to make it work in automated way, without any prompts
        ]
    }

  connection {
        type = "ssh"
        user = "${var.ansible_user}"
        private_key = file(var.private_key)
        host = var.ip_address
  }

}