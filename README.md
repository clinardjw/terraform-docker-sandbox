# Terraform Docker Sandbox

![Terraform checks](https://github.com/clinardjw/terraform-docker-sandbox/actions/workflows/terraform.yml/badge.svg)

A small infrastructure-as-code lab that uses Terraform to stand up a local Docker environment: a public-facing **nginx** web server and a private **Redis** cache on a shared network.

One reusable module builds both containers. The only difference is whether a port gets exposed to the host.

## What it builds

```mermaid
flowchart LR
    host["Your machine<br/>localhost:8080"] -->|port 8080 → 80| nginx

    subgraph net["Docker network: tf-sandbox-net"]
        nginx["tf-sandbox-nginx<br/>nginx:latest"]
        redis["tf-sandbox-redis<br/>redis:alpine"]
        nginx -.->|reachable by name| redis
    end
```

| Resource | Image | Reachable from host? | Reachable on network? |
|---|---|---|---|
| `tf-sandbox-nginx` | `nginx:latest` | Yes, on `localhost:8080` | Yes |
| `tf-sandbox-redis` | `redis:alpine` | No | Yes, as `tf-sandbox-redis:6379` |
| `tf-sandbox-net` | Docker network | n/a | n/a |

## Project structure

```
.
├── main.tf              # Network plus the nginx and redis module calls
├── variables.tf         # host_port (default 8080)
├── outputs.tf           # URL, network name, container names
├── site/
│   └── index.html       # Custom page uploaded into the nginx container
├── versions.tf          # Terraform and Docker provider requirements
├── .github/workflows/
│   └── terraform.yml    # CI: terraform fmt -check and validate on every push
└── modules/
    └── web-container/   # Reusable module: image + container + optional port
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

## How the module works

`modules/web-container` pulls an image, starts a container, and attaches it to a network. The port mapping is optional, controlled by a `dynamic` block:

```hcl
dynamic "ports" {
  for_each = var.internal_port != null ? [1] : []
  content {
    internal = var.internal_port
    external = var.external_port
  }
}
```

- **nginx** passes `internal_port = 80` and `external_port = var.host_port`, so the block is created and the site is published to the host.
- **redis** passes no ports, so the block is skipped entirely. Redis is only reachable by other containers on `tf-sandbox-net`.

Same module, two very different exposure levels, with no duplicated code.

The module also takes an optional `uploads` list for copying files into a container. The root config uses it to replace nginx's default welcome page with `site/index.html`. Edit that file and run `terraform apply` again, and Terraform replaces the container with the new page.

## Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install) 1.5 or newer
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or another local Docker daemon) running
- The [kreuzwerker/docker](https://registry.terraform.io/providers/kreuzwerker/docker/latest) provider (~> 3.0), installed automatically by `terraform init`

## Usage

```bash
terraform init
terraform plan
terraform apply
```

Then open the URL from the outputs to see the custom page:

```
url = "http://localhost:8080"
```

Use a different host port if 8080 is taken:

```bash
terraform apply -var="host_port=8081"
```

### Verify the network isolation

nginx answers on the host:

```bash
curl http://localhost:8080
```

Redis does not publish a port, but it answers from inside the network:

```bash
docker run --rm --network tf-sandbox-net redis:alpine redis-cli -h tf-sandbox-redis ping
# PONG
```

### Tear it down

```bash
terraform destroy
```

Pulled images are removed on destroy by default. Set `keep_image_locally = true` in a module call to keep them.

## Outputs

| Output | Description |
|---|---|
| `url` | Address of the nginx container on your machine |
| `network_name` | Name of the shared Docker network |
| `web_container_name` | Name of the nginx container |
| `cache_container_name` | Name of the Redis container |

## Roadmap

- [x] GitHub Actions workflow running `terraform fmt -check` and `terraform validate` on every push
- [x] Serve a custom page from nginx
- [ ] Add a small app container that reads and writes to Redis
- [ ] Health checks on both containers
