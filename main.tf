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

  # Replace nginx's default welcome page with our own
  uploads = [
    {
      file    = "/usr/share/nginx/html/index.html"
      content = file("${path.module}/site/index.html")
    }
  ]
}

# redis: no internal_port/external_port passed, so the module skips
# creating a ports block entirely. It is only reachable inside the network.
module "redis" {
  source = "./modules/web-container"

  container_name = "tf-sandbox-redis"
  image_name     = "redis:alpine"
  network_name   = docker_network.sandbox.name
}

# worker: a tiny "app" that talks to redis over the shared network.
# Every 5 seconds it increments a counter and prints the new value.
# It reuses the redis:alpine image just for its redis-cli tool.
module "worker" {
  source = "./modules/web-container"

  container_name     = "tf-sandbox-worker"
  image_name         = "redis:alpine"
  network_name       = docker_network.sandbox.name
  keep_image_locally = true # the redis module manages this image too

  command = [
    "sh", "-c",
    "while true; do redis-cli -h ${module.redis.container_name} INCR sandbox:heartbeats; sleep 5; done"
  ]
}
