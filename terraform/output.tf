output "server_ip_nodes" {
  description =	"Public IPs of all devops_vm nodes"
  value = [
    for server in hcloud_server.devops_vm : server.ipv4_address
  ]
}


