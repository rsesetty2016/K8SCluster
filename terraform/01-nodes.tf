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
  ansible_user        = lookup(var.ansible_user, terraform.workspace)
  ansible_host        = lookup(var.ansible_host, terraform.workspace)
  ansible_home_dir    = lookup(var.ansible_home_directory, terraform.workspace)
  ha_entry_ip         = lookup(var.ha_entry_ip, terraform.workspace)
  nfs_server_ip = lookup(var.nfs_server, terraform.workspace).server
  nfs_server_mount_path = lookup(var.nfs_server, terraform.workspace).mount_point
  nfs_client_path = lookup(var.nfs_client_path, terraform.workspace)
  k8_control_ip = lookup(var.k8_control_ip, terraform.workspace)
nfs_storage_size = lookup(var.nfs_server, terraform.workspace).size
ceph = lookup(var.ceph_server, terraform.workspace)
tls_kube_key = lookup(var.tls_kube_key, terraform.workspace)
tls_kube_cert = lookup(var.tls_kube_cert, terraform.workspace)
tls_kube_ca_cert = lookup(var.tls_kube_ca_cert, terraform.workspace)
}

# module "prep_work" { # Started this build /etc/hosts table dynamically from the variables.tf file.
#     source = "../terraform-modules/pre-install"
#     hosts = local.nodes
# }

output "prep_work_operational_status" {
    value = local.nfs_server_mount_path
}

module "node" {
  source = "../terraform-modules/base-node"
    count             = length(local.nodes.host)
  # count             = 2
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

output "hosts_created" {
  value = module.node[*].host_created
}

output "cloud_init_file" {
  value = module.node[*].cloud_init_file
}

module "bastion" {
  source              = "../terraform-modules/bastion"
  for_each            = toset(local.nodes.host)
  host_type           = local.nodes.host_details[each.key].host_type
  ansible_public_key  = local.ansible_public_key
  ansible_private_key = local.ansible_private_key
  private_key         = local.private_key
  ansible_user        = local.ansible_user
  ip_address          = local.nodes.host_details[each.key].ip
  ansible_home_dir    = local.ansible_home_dir
  ha_entry_ip         = local.ha_entry_ip
  k8_control_ip       = local.k8_control_ip
  ansible_secret_file = var.ansible_secret_file
  ansible_secret_path = var.ansible_secret_path
  ansible_pwd         = var.ansible_pwd
  depends_on          = [module.node]
}

module "k8cluster" {
  source    = "../terraform-modules/k8cluster"
  for_each  = toset(local.nodes.host)
  host_type = local.nodes.host_details[each.key].host_type
  ha_ip = local.ha_entry_ip
  kubelet_version = var.k8_kubelet_version
  kubeadm_version = var.k8_kubeadm_version
  kubectl_version = var.k8_kubectl_version
  ceph = local.ceph
  ceph_key = var.ceph_key
  nfs_server = local.nfs_server_ip
  nfs_server_mount_path = local.nfs_server_mount_path
  nfs_storage_size = local.nfs_storage_size
  nfs_client_path = local.nfs_client_path
  host_ip = local.nodes.host_details[each.key].ip
  ansible_host = local.ansible_host
    ansible_public_key  = local.ansible_public_key
  ansible_private_key = local.ansible_private_key
  private_key         = local.private_key
  depends_on          = [module.bastion]
  tls_kube_ca_cert = local.tls_kube_ca_cert
  tls_kube_cert = local.tls_kube_cert
  tls_kube_key = local.tls_kube_key
}

# module "k8sworker" {
#   source    = "../terraform-modules/k8sworker"
#   for_each  = toset(local.nodes.host)
#   host_type = local.nodes.host_details[each.key].host_type
#   #   ansible_public_key  = local.ansible_public_key
#   # ansible_private_key = local.ansible_private_key
#   # private_key         = local.private_key
# }
