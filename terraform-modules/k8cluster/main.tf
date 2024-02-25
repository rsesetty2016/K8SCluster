resource "null_resource" "k8_cluster_init" {
  
count = var.host_type == "control" || var.host_type == "worker" ? 1 : 0

  provisioner "file" {
    source = "${path.module}/../bastion/initial_repo/${terraform.workspace}_hosts.txt"
    destination = "/tmp/hosts.txt"
  }

  # provisioner "file" {
  #   source = "${path.module}/files"
  #   destination = "/tmp"
  # }

  provisioner "file" {
    source = "${path.module}/../bastion/initial_repo/files"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
        "curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes.gpg",
        "echo \"deb [arch=amd64 signed-by=/etc/apt/keyrings/kubernetes.gpg] http://apt.kubernetes.io/ kubernetes-xenial main\" | sudo tee -a /etc/apt/sources.list",
        "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/helm.gpg > /dev/null",
        "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main\" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list",
        "sudo apt-get update -y", # Update apt package index,
        "sudo apt-get install -y kubelet=${var.kubelet_version} kubeadm=${var.kubeadm_version} kubectl=${var.kubectl_version}", # Install Docker Engine, kubelet, kubeadm and kubectl
        "sudo apt-mark hold kubelet kubeadm kubectl", # pin kubelet kubeadm kubectl version
        "sudo sysctl --system", # Reload settings from all system configuration files to take iptables configuration
        "sudo swapoff -a",
        "sudo sed -i '/ swap / s/^\\(.*\\)$/#\\1/g' /etc/fstab",
        "sudo sysctl net.bridge.bridge-nf-call-iptables=1",
        "sudo sysctl --system",
        "echo '${var.ceph_key}' > /tmp/files/ceph_key.txt",
      "sh /tmp/files/k8_script.sh ${var.ceph.name} ${var.ceph.storage} ${var.ceph.accessModes} ${var.ceph.monitors} ${var.ceph.pool} ${var.ceph.image} ${var.ceph.user} ${var.ceph.secret} ${var.ceph.fsType} ${var.ceph.readOnly} ${var.nfs_server} ${var.nfs_server_mount_path} ${var.nfs_storage_size} ${var.host_ip} ${var.ha_ip}",
      "echo 'kubeadm init --control-plane-endpoint ${var.ha_ip}:6443 --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=${var.host_ip}' > /tmp/k8_init.sh"
    ]   
  }
 connection {
        type = "ssh"
        user = "proxuser"
        private_key = file(var.private_key)
        host = var.host_ip
  }
}

resource "null_resource" "prep_for_ansible" {
  
  count = var.host_type == "control" ? 1 : 0

  depends_on = [
    null_resource.ansible_initialization
  ]

  provisioner "file" {
    source = "${var.ansible_public_key}"
    destination = "/tmp/ansible_public.key"
  }

  provisioner "remote-exec" {
    inline = [
      "cat /tmp/ansible_public.key >> ~/.ssh/authorized_keys"
    ]
  }
 connection {
        type = "ssh"
        user = "svc_ansible"
        private_key = file(var.private_key)
        host = var.host_ip
  }
}

resource "null_resource" "ansible_initialization" {

    count = var.host_type == "control" ? 1 : 0
  depends_on = [
    null_resource.k8_cluster_init
  ]

  provisioner "file" {
    source = "${var.tls_kube_ca_cert}"
    destination = "/tmp/tls_kube_ca_cert.pem"
  }

  provisioner "file" {
    source = "${var.tls_kube_cert}"
    destination = "/tmp/tls_kube_cert.pem"
  }

    provisioner "file" {
    source = "${var.tls_kube_key}"
    destination = "/tmp/tls_kube_key.pem"
  }



  provisioner "remote-exec" {
    inline = [
      ". /projects/ansible/initial_repo/ansible_initial_script.sh"
    ]
  }

  connection {
    type = "ssh"
    user = "svc_ansible"
    private_key = file(var.private_key)
    host = var.ansible_host
  }
}
