terraform {
  required_providers {
    cloudsigma = {
      source  = "cloudsigma/cloudsigma"
      version = "1.6.0"
    }
  }
}

provider "cloudsigma" {
  username = var.cloudsigma_username
  password = var.cloudsigma_password
  location = var.cloudsigma_location
}

# SSH key is used to provision k3s_server and k3s_worker nodes
resource "cloudsigma_ssh_key" "k3s" {
  name        = "k3s"
  private_key = file(var.private_key)
  public_key  = file(var.public_key)
}

resource "cloudsigma_tag" "k3s" {
  name = "k3s"
}

# generate random k3s token
resource "random_string" "k3s_token" {
  length  = 48
  upper   = false
  special = false
}

module "k3s_server" {
  source = "./k3s-server"
  count  = 1

  name        = "k3s-server-${count.index}"
  private_key = file(var.private_key)
  ssh_uuid    = cloudsigma_ssh_key.k3s.id
  tag_uuid    = cloudsigma_tag.k3s.id
}

module "k3s_agent" {
  source = "./k3s-agent"
  count  = 2

  name        = "k3s-agent-${count.index}"
  private_key = file(var.private_key)
  ssh_uuid    = cloudsigma_ssh_key.k3s.id
  tag_uuid    = cloudsigma_tag.k3s.id
}

# install and boostrap k3s on server instance
resource "null_resource" "bootstrap_k3s_server" {
  provisioner "file" {
    source      = "provisioning/100_k3s-server-install.sh"
    destination = "/tmp/provisioning/100_k3s-server-install.sh"

    connection {
      host        = module.k3s_server[0].instance.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = file(var.private_key)
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = module.k3s_server[0].instance.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = file(var.private_key)
    }

    inline = [
      "sudo chmod +x /tmp/provisioning/*",
      "/tmp/provisioning/100_k3s-server-install.sh ${random_string.k3s_token.result}"
    ]
  }

  depends_on = [module.k3s_server]
}

# install and boostrap k3s on agent instances
resource "null_resource" "bootstrap_k3s_agent" {
  count = length(module.k3s_agent)

  provisioner "file" {
    source      = "provisioning/100_k3s-agent-install.sh"
    destination = "/tmp/provisioning/100_k3s-agent-install.sh"

    connection {
      host        = module.k3s_agent["${count.index}"].instance.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = file(var.private_key)
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = module.k3s_agent["${count.index}"].instance.ipv4_address
      type        = "ssh"
      user        = "cloudsigma"
      private_key = file(var.private_key)
    }

    inline = [
      "sudo chmod +x /tmp/provisioning/*",
      "/tmp/provisioning/100_k3s-agent-install.sh ${random_string.k3s_token.result} ${module.k3s_server[0].instance.ipv4_address}"
    ]
  }

  depends_on = [module.k3s_agent]
}
