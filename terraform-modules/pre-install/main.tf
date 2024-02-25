locals {
    x = join("\t", var.hosts.host)
}

resource "local_file" "build_hosts_table" {
    filename = "${path.module}/../../cloud-init/x.txt"
    content = local.x
}

output "operation_status" { 
    value = local.x
}