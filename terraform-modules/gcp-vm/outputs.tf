output "instances" {
  value = { for k, v in google_compute_instance.vm : k => { id = v.id, name = v.name, zone = v.zone, network_ip = try(v.network_interface[0].network_ip, "") } }
}
