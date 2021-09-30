output "k3_servers_ipv4_addresses" {
  value = module.k3s_server.*.instance.ipv4_address
}

output "k3_agents_ipv4_addresses" {
  value = module.k3s_agent.*.instance.ipv4_address
}
