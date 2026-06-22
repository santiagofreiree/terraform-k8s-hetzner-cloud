# Variables for Hetzner Infrastructure

# Note: HCLOUD_TOKEN is read from environment variable automatically by the provider
# export HCLOUD_TOKEN="your-token-here"

variable "primary_ip_id" {
  description = "ID of the existing primary IP"
  type        = string

  validation {
    condition     = can(regex("^[0-9]+$", var.primary_ip_id))
    error_message = "Floating IP ID must be a numeric value."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"

  validation {
    condition     = fileexists(pathexpand(var.ssh_public_key_path))
    error_message = "SSH public key file must exist at the specified path."
  }
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key (for provisioner connections)"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
  default     = "nuevo-cluster"

}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1"

  validation {
    condition     = contains(["nbg1", "fsn1", "hel1", "ash"], var.location)
    error_message = "Location must be a valid Hetzner Cloud location (nbg1, fsn1, hel1, ash)."
  }
}

variable "network_zone" {
  description = "Hetzner network zone"
  type        = string
  default     = "eu-central"

  validation {
    condition     = contains(["eu-central", "us-east", "us-west"], var.network_zone)
    error_message = "Network zone must be eu-central, us-east, or us-west."
  }
}

variable "network_cidr" {
  description = "CIDR block for the private network"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Network CIDR must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid CIDR block (e.g., 10.0.1.0/24)."
  }
}

variable "allowed_ssh_ips" {
  description = "List of allowed IP addresses for SSH access (empty list allows all)"
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for ip in var.allowed_ssh_ips : can(cidrhost(ip, 0))])
    error_message = "All SSH IP addresses must be valid CIDR blocks."
  }
}

variable "volume_label" {
  description = "Filesystem label for the volume"
  type        = string
  default     = "data-volume"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,16}$", var.volume_label))
    error_message = "Volume label must be alphanumeric with hyphens/underscores, max 16 characters."
  }
}

variable "nfs_export_clients" {
  description = "List of client networks allowed to access NFS exports"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = alltrue([for cidr in var.nfs_export_clients : can(cidrhost(cidr, 0))])
    error_message = "All NFS export client addresses must be valid CIDR blocks."
  }
}

variable "enable_fail2ban" {
  description = "Whether to install and configure fail2ban"
  type        = bool
  default     = true
}

variable "admin_email" {
  description = "Admin email address for notifications"
  type        = string
  default     = "admin@cloud.sysmarketsa.com"

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "Admin email must be a valid email address."
  }
}

