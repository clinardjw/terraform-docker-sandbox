variable "container_name" {
  description = "Name to give the running container"
  type        = string
}

variable "image_name" {
  description = "Docker image to pull, e.g. \"nginx:latest\""
  type        = string
}

variable "network_name" {
  description = "Name of the Docker network to attach this container to"
  type        = string
}

variable "keep_image_locally" {
  description = "If true, `terraform destroy` will leave the pulled image in place"
  type        = bool
  default     = false
}

variable "internal_port" {
  description = "Port the container listens on internally. Set to null to skip exposing any port (e.g. for a backend service like redis that's only reached by other containers)."
  type        = number
  default     = null
}

variable "external_port" {
  description = "Port on the host machine to map to internal_port. Only used if internal_port is set."
  type        = number
  default     = null
}

variable "host_port" {
  description = "Port on your local machine that maps to the container's port 80"
  type        = number
  default     = 8080
}