# Shared network so both containers can reach each other by name.
resource "docker_network" "sandbox" {
  name = "tf-sandbox-net"
}

# nginx: exposed to the host machine on var.host_port
module "nginx" {
  source = "./modules/web-container"

  container_name = "tf-sandbox-nginx"
  image_name     = "nginx:latest"
  network_name   = docker_network.sandbox.name
  internal_port  = 80
  external_port  = var.host_port
}

# redis: no internal_port/external_port passed, so the module skips
# creating a ports block entirely — only reachable inside the network.
module "redis" {
  source = "./modules/web-container"

  container_name = "tf-sandbox-redis"
  image_name     = "redis:alpine"
  network_name   = docker_network.sandbox.name
}