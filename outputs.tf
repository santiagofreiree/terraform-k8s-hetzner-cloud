# Output definitions for Terraform infrastructure
# These outputs provide essential information about created resources

output "server_ip" {
  description = "The IPv4 address of the server"
  value       = hcloud_server.worker0.ipv4_address
}

output "server_private_ip" {
  description = "The private IPv4 address of the server"
  value       = tolist(hcloud_server.worker0.network)[0].ip
}

output "network_id" {
  description = "The ID of the created network"
  value       = hcloud_network.private.id
}

output "ssh_key_id" {
  description = "The ID of the created SSH key"
  value       = hcloud_ssh_key.default.id
}

output "ssh_key_fingerprint" {
  description = "The fingerprint of the created SSH key"
  value       = hcloud_ssh_key.default.fingerprint
}

output "server_id" {
  description = "The ID of the created server"
  value       = hcloud_server.worker0.id
}

output "control_plane_private_ip" {
  description = "The private IPv4 address of the control plane server"
  value       = cidrhost(var.subnet_cidr, 10)
}

output "ssh_jump_command" {
  description = "SSH command to access control plane via router bastion"
  value       = "ssh -J root@${hcloud_server.worker0.ipv4_address} root@${cidrhost(var.subnet_cidr, 10)}"
}


output "access_instructions" {
  description = "Instructions to access the infrastructure"
  value       = <<-EOT
    === ROUTER (NAT Gateway + NFS Server) ===
    Public IP: ${hcloud_server.worker0.ipv4_address}
    Private IP: ${cidrhost(var.subnet_cidr, 2)}
    SSH: ssh root@${hcloud_server.worker0.ipv4_address}
    
    === CONTROL PLANE (Kubernetes Master) ===
    Private IP: ${cidrhost(var.subnet_cidr, 10)}
    SSH via bastion: ssh -J root@${hcloud_server.worker0.ipv4_address} root@${cidrhost(var.subnet_cidr, 10)}
    
    === KUBERNETES ACCESS ===
    1. SSH to control plane: ssh -J root@${hcloud_server.worker0.ipv4_address} root@${cidrhost(var.subnet_cidr, 10)}
    2. kubectl is configured at /root/.kube/config
    3. Check cluster status: kubectl get nodes
    4. Check Cilium status: cilium status
    
    === NFS MOUNT (on client servers) ===
    mount -t nfs ${cidrhost(var.subnet_cidr, 2)}:/exports/nfs /mnt/nfs
    
    === GET KUBEADM JOIN TOKEN ===
    From control plane run: kubeadm token create --print-join-command
  EOT
}
