locals {

nodes               = lookup(var.nodes, "sbb")
     hosts = tolist(local.nodes.host)
     host_contents = ""
    host_details = {
    for h in local.hosts:
        h => { "ip": local.nodes.host_details[h].ip, "alias": local.nodes.host_details[h].host_alias}
    }
}

output "display" {
    value = local.host_details
}

resource "local_file" "ec2_iini" {
  filename = "hosts.txt"
  content = <<-EOT
    %{ for h in local.hosts ~}
    ${local.host_details[h].ip}  ${local.host_details[h].alias} 
    %{ endfor ~}
    EOT
}

module test {
    source = "./modules/test"
}

output "test" { 
    value = module.test.summary
}

