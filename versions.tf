terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.5"
}

provider "docker" {
  # Uses your local Docker daemon (Docker Desktop / dockerd) automatically.
  # No credentials needed for local use.
}
