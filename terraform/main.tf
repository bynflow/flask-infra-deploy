/*
Questo file di configurazione crea un numero 'x' di server (il valore di 'count_x' è nel file con estensione '.tfvars').
In ciascuno di questi server Ansible, lanciato dal primo server-0, il controller, eseguirà docker il quale attraverso un
Dockerfile installerà uno o più container.
*/

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "devops_vm" {
  count	      = var.count_x
  name        = "flask-server-${count.index}"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = var.ssh_key_name

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
    
  connection  {
    type	= "ssh"
    user	= "root"
    private_key	= file("~/.ssh/id_ed25519")
    host	= self.ipv4_address
  }

# Copia della cartella Ansible su tutti i server
provisioner "file" {
    source      = "../ansible"
    destination = "/root/"
    connection {
      type = "ssh"
      user = "root"
      private_key = file("~/.ssh/id_ed25519")
      host = self.ipv4_address
    }
  }

  # Copia della chiave privata su ogni server per autenticazione SSH da Ansible
  provisioner "file" {
    source      = "~/.ssh/id_ed25519"
    destination = "/root/.ssh/id_ed25519"
    connection {
      type = "ssh"
      user = "root"
      private_key = file("~/.ssh/id_ed25519")
      host = self.ipv4_address
    }
  }

  provisioner "remote-exec"  {
    inline  =  [
      "if [ ${count.index} -eq 0 ]; then chmod 600 /root/.ssh/id_ed25519; fi"
    ]
  }

  # Installare Ansible (i pacchetti python3, python3-pip e pip3 sono tuttavia necessari ad ansible su ogni server target) su flask-server-0
  provisioner "remote-exec"  {
    inline  =  [
      "if [ ${count.index} -eq 0 ]; then apt update -y; apt install -y python3 python3-pip; pip3 install --break-system-packages ansible; ansible --version > /root/ansible_version.log; fi"
    ]
  }
}

# Creiamo un `null_resource` per generare l'inventario
resource "null_resource" "generate_inventory" {
  depends_on = [hcloud_server.devops_vm]

  provisioner "file" {
    content     = templatefile("${path.module}/ansible_hosts.tmpl", {
      ips = hcloud_server.devops_vm[*].ipv4_address
    })
    destination = "/root/ansible_hosts"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
      host        = hcloud_server.devops_vm[0].ipv4_address
    }
  }
}

# Creazione del file known_hosts
resource "null_resource" "generate_known_hosts" {
  depends_on = [hcloud_server.devops_vm]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
      host        = hcloud_server.devops_vm[0].ipv4_address
    }
    
    inline = [
      "mkdir -p /root/.ssh",
      "chmod 700 /root/.ssh",
      "touch /root/.ssh/known_hosts",
      "chmod 600 /root/.ssh/known_hosts",
      "for ip in ${join(" ", hcloud_server.devops_vm[*].ipv4_address)}; do ssh-keyscan -H $ip >> /root/.ssh/known_hosts; done"
    ]
  }
}

# Lanciare Ansible solo su flask-server-0
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.generate_known_hosts]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
      host        = hcloud_server.devops_vm[0].ipv4_address
      timeout     = "30m"
    }
    
    inline = [
      "chmod -R 755 /root/ansible",
      "ANSIBLE_HOST_KEY_CHECKING=False ANSIBLE_LOG_PATH=/root/ansible/ansible_detailed.log ansible-playbook -i /root/ansible_hosts -u root --private-key=/root/.ssh/id_ed25519 /root/ansible/playbook.yml -vvvv > /root/ansible/ansible_run_output.log 2>&1"
    ]
  }
}

# Lanciare HAProxy dall'omonimo playbook ansible solo su flask-server-0 e dopo "run_ansible"
resource "null_resource" "run_haproxy" {
  depends_on = [null_resource.run_ansible]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("~/.ssh/id_ed25519")
      host        = hcloud_server.devops_vm[0].ipv4_address
      timeout     = "30m"
    }

    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /root/ansible_hosts /root/ansible/haproxy.yml -vvvv > /root/ansible/haproxy_run.log 2>&1"
    ]
  }
}


