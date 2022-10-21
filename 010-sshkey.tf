# Define ssh to config in instance

resource "openstack_compute_keypair_v2" "user_key" {
  name       = "user-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFDVr0cqnR+I86DuSLo1PvY6d65idcoYu+rBz/QC5ot7uVfUUXNcTWYoY3z0/vtnWUySOTBojkYBDr6OYiQE8aoWWac4z3jcvYoWQrPYkB8GQalMzVUn7vx5x585zmkmZZ74EuUqd8W+L4Ln/d96hRXvAFhVePKi6Anb2fjlL+y+bvRMmJY4ePBiz1/wTZ2PNrNWbXz62t/2Hi3Ci8dzjUtqrwAPWpHnVaMUx4/h54MZmmQmQnCsMlB2vMuGXbRfy0mlFQ7lNG2XuPp2DhzEsov0d6LlP8liWK0zSQ8OWITSTPY1VZnqmM4oiYrxfFIGtWQbE40RmOo6mTPIbCROLV"
}

