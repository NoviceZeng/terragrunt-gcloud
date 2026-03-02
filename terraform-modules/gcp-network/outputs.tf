output "network_name" {
  description = "Created VPC network name"
  value       = google_compute_network.vpc.name
}

output "network_self_link" {
  description = "Created VPC network self link"
  value       = google_compute_network.vpc.self_link
}

output "subnet_self_links" {
  description = "Map of subnet name to subnet self link"
  value       = { for name, subnet in google_compute_subnetwork.subnets : name => subnet.self_link }
}
