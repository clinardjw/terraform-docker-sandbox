resource "docker_image" "this" {
  name         = var.image_name
  keep_locally = var.keep_image_locally
}

resource "docker_container" "this" {
  name    = var.container_name
  image   = docker_image.this.image_id
  command = var.command

  networks_advanced {
    name = var.network_name
  }

  # Only include a ports block at all if internal_port was set.
  # This is how the same module serves both "exposed to host" (nginx)
  # and "network-only" (redis) containers.
  dynamic "ports" {
    for_each = var.internal_port != null ? [1] : []
    content {
      internal = var.internal_port
      external = var.external_port
    }
  }

  # Copy files (like a custom web page) into the container at creation time.
  # Changing a file's content replaces the container on the next apply.
  dynamic "upload" {
    for_each = var.uploads
    content {
      file    = upload.value.file
      content = upload.value.content
    }
  }
}
