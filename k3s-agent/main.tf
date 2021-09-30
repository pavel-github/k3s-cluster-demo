terraform {
  required_providers {
    cloudsigma = {
      source  = "cloudsigma/cloudsigma"
      version = "1.6.0"
    }
  }
}

# find Debian 10.10 server image for cloning later
data "cloudsigma_library_drive" "debian" {
  filter {
    name   = "name"
    values = ["Debian 10.10 Server"]
  }
}

resource "cloudsigma_drive" "k3s_agent" {
  clone_drive_id = data.cloudsigma_library_drive.debian.id

  media = "disk"
  name  = var.name
  size  = 15 * 1024 * 1024 * 1024

}

resource "cloudsigma_server" "k3s_agent" {
  cpu          = 2 * 1000
  memory       = 2 * 1024 * 1024 * 1024
  name         = var.name
  smp          = 2
  vnc_password = "vnc_k3s-agent"

  drive {
    uuid = cloudsigma_drive.k3s_agent.id
  }

  network {
    type = "dhcp"
  }

  ssh_keys = [var.ssh_uuid]
  tags     = [var.tag_uuid]

  provisioner "file" {
    source      = "${path.module}/provisioning"
    destination = "/tmp"

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = var.private_key
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = var.private_key
    }

    inline = [
      "sudo chmod +x /tmp/provisioning/*",
      "/tmp/provisioning/000_system-update.sh ${var.name}",
    ]
  }
}
