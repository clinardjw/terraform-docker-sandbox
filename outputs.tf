output "web_container_name" {
  value = module.nginx.container_name
}

output "url" {
  value = "http://localhost:${var.host_port}"
}

output "network_name" {
  value = docker_network.sandbox.name
}

output "cache_container_name" {
  value = module.redis.container_name
}

output "worker_container_name" {
  value = module.worker.container_name
}
