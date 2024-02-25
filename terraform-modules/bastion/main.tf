resource "null_resource" "copy_docker_files" {
        count = var.host_type == "bastion" ? 1 : 0

#   depends_on = [
#     proxmox_vm_qemu.bastion-host, null_resource.cloud_init_config_bastion
#   ]

  provisioner "file" {
    source = "${path.module}/ha/files"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait", 
       "sh /tmp/files/docker_command_ha.sh ${var.ha_entry_ip} ${var.k8_control_ip}",
    "sudo mkdir -p /projects/docker/ha",
    "sudo chown -R svc_ansible:svc_ansible /projects/docker/ha",
    "sudo mkdir -p /projects/ansible/.ssh",
    "sudo chown -R svc_ansible:svc_ansible /projects/ansible",
    "ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -q -N ''",
    "sudo mkdir -p /var/lib/secure/ansible",
    "sudo touch /var/lib/secure/ansible/.ansible.pw",
    "sudo chown -R svc_ansible:svc_ansible /var/lib/secure/ansible",
    "sudo chmod 600 /var/lib/secure/ansible/.ansible.pw",
    "sudo add-apt-repository --yes --update ppa:ansible/ansible > /dev/null",
    "sudo apt update -y > /dev/null",
    "sudo apt install -y ansible",
    "sudo sh -c 'ansible-config init --disabled > /etc/ansible/ansible.cfg'",
    "sudo sh -c \"echo 'private_key_file = ~/.ssh/ansible_private.key' >> /etc/ansible/ansible.cfg\""
    ]
  }

  connection {
        type = "ssh"
        user = "${var.ansible_user}"
        private_key = file(var.private_key)
        host = var.ip_address
  }

}

resource "null_resource" "post_process" {
    

  depends_on = [
    null_resource.copy_docker_files
  ]

    count = var.host_type == "bastion" ? 1 : 0


  provisioner "file" {
    source = "${path.module}/initial_repo"
    destination = "${var.ansible_home_dir}"
  }

  provisioner "file" {
    source = "${path.module}/initial_repo/${terraform.workspace}_inventory.yml"
    destination = "${var.ansible_home_dir}/initial_repo/inventory.yml"
  }

  provisioner "file" {
    source = "${var.ansible_private_key}"
    destination = "${var.ansible_home_dir}/.ssh/ansible_private.key"
  }

  provisioner "file" {
    source = "${var.ansible_public_key}"
    destination = "${var.ansible_home_dir}/.ssh/ansible_public.key"
  }


  provisioner "remote-exec" {
    inline = [
        "sh ${var.ansible_home_dir}/initial_repo/update_profile.sh ${var.ansible_home_dir} ${var.ansible_secret_path} ${var.ansible_secret_file} ${var.ansible_pwd} ${var.ansible_user} > /tmp/update_profile.log 2>&1 ",
        "chmod go-r /projects/ansible/.ssh/ansi*.key",
        "cat ${var.ansible_home_dir}/.ssh/ansible_public.key >> ~/.ssh/authorized_keys"
    ]
  }

  connection {
        type = "ssh"
        user = "${var.ansible_user}"
        private_key = file(var.private_key)
        host = var.ip_address
  }

}