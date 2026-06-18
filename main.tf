terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
  required_version = ">= 1.0"
}

# Hetzner provider - token read from HCLOUD_TOKEN environment variable
provider "hcloud" {}

# Local values for configuration
locals {
  # Derive private key path from public key path if not provided
  # Assumes standard naming: id_rsa.pub -> id_rsa
  private_key_path = var.ssh_private_key_path != null ? var.ssh_private_key_path : replace(var.ssh_public_key_path, ".pub", "")
}

# SSH Key resource
resource "hcloud_ssh_key" "default" {
  name       = "${var.cluster_name}-ssh-key"
  public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

# Network resource
resource "hcloud_network" "private" {
  name     = "${var.cluster_name}-network"
  ip_range = var.network_cidr
  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}

# Subnet resource
resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_cidr
}


# Server resource - Router and NFS Gateway
resource "hcloud_server" "worker0" {
  name        = "worker0"
  server_type = "cx33"
  image       = "ubuntu-26.04"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels = {
    role = "worker0"
  }

  public_net {
    ipv4_enabled = true
    ipv4         = var.primary_ip_id
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(var.subnet_cidr, 2)
  }

  depends_on = [hcloud_network_subnet.subnet]

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }


}

# Server resource - worker1
resource "hcloud_server" "worker1" {
  name        = "worker1"
  server_type = "cx33"
  image       = "ubuntu-26.04"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels = {
    role = "worker1"
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(var.subnet_cidr, 21)
  }

  depends_on = [hcloud_network_subnet.subnet]

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }
}


# Control Plane Server with Kubernetes

# Control Plane Server with Kubernetes
resource "hcloud_server" "control_plane" {
  name        = "controlplane"
  server_type = "cx23"
  image       = "ubuntu-26.04"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels = {
    role = "control-plane-master"
  }

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private.id
    ip         = cidrhost(var.subnet_cidr, 10)
  }

  depends_on = [hcloud_network_subnet.subnet, hcloud_server.worker0]

  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

}

resource "hcloud_network_route" "default_route" {
  network_id  = hcloud_network.private.id
  destination = "0.0.0.0/0"
  gateway     = cidrhost(var.subnet_cidr, 2) # Your NAT server's private IP
}
