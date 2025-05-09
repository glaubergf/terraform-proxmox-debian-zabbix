# Origem do arquivo de configuração do Cloud Init.
data "template_file" "cloud_init" {
  template = file(var.cloud_config_file)

  vars = {
    ssh_key  = file(var.ssh_key)
    hostname = var.vm_hostname
    domain   = var.vm_domain
    password = var.vm_password
    user     = var.vm_user
  }
}

data "template_file" "network_config" {
  template = file(var.network_config_file)
}

# Criar uma cópia local dos arquivos para transferir para o servidor Proxmox.
resource "local_file" "cloud_init" {
  content  = data.template_file.cloud_init.rendered
  filename = "${path.module}/configs/zabbix_cloud_init.cfg"
}

resource "local_file" "network_config" {
  content  = data.template_file.network_config.rendered
  filename = "${path.module}/configs/zabbix_network_config.cfg"
}

# Transferir os arquivos para o servidor Proxmox.
resource "null_resource" "cloud_init" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key)
    host        = var.srv_proxmox
  }

  provisioner "file" {
    source      = local_file.cloud_init.filename
    destination = "/var/lib/vz/snippets/zabbix_cloud_init.yml"
  }

  provisioner "file" {
    source      = local_file.network_config.filename
    destination = "/var/lib/vz/snippets/zabbix_network_config.yml"
  }
}

# Copiar o script de template para o servidor Proxmox e executá-lo.
resource "null_resource" "proxmox_template_script" {
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key)
    host        = var.srv_proxmox
  }

  # Copiar o script para o Proxmox.
  provisioner "file" {
    source      = var.vm_template_script_path
    destination = "/tmp/vm_template.sh"
  }

  # Executar o script no Proxmox.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vm_template.sh",
      "bash /tmp/vm_template.sh"
    ]
  }
}

# Criar a VM, depende da execução do script no Proxmox.
resource "proxmox_vm_qemu" "debian_nocloud" {
  depends_on = [
    null_resource.proxmox_template_script,
    null_resource.cloud_init
  ]

  name        = var.vm
  target_node = var.node

  # Clonar o modelo 'bookworm-cloudinit'.
  clone   = var.template
  os_type = "cloud-init"

  # Opções do Cloud Init
  cicustom = "user=${var.storage_proxmox}:snippets/zabbix_cloud_init.yml,network=${var.storage_proxmox}:snippets/zabbix_network_config.yml"

  # Configurações de hardware.
  vmid    = var.vm_vmid
  cores   = var.vm_cores
  memory  = var.vm_memory
  sockets = 1
  agent   = 1
  kvm     = true
  numa    = false
  onboot  = true

  # Definir os parâmetros do disco de inicialização bootdisk = "scsi0".
  scsihw = "virtio-scsi-pci" # virtio-scsi-single

  # Configurar disco principal
  disk {
    slot     = "scsi0"
    type     = "disk"
    format   = "raw"
    iothread = true
    storage  = var.storage_proxmox
    size     = var.disk_size
  }

  # Configurar drive do CloudInit.
  disk {
    slot = "ide2"
    type = "cloudinit" # o Proxmox ignora o parâmetro 'format' quando usa type 'cloudinit'.
    #format  = "qcow2"
    storage = var.storage_proxmox
  }

  # Ordem de boot.
  boot = "order=scsi0;ide2"

  # Adicionar configuração de BIOS (UEFI 'ovmf' / BIOS tradicional 'seabios').
  bios = "seabios"

  # Aumentar o tempo de espera para o agente QEMU, se necessário.
  agent_timeout = 60

  # Desabilitar a verificação de IPv6.
  skip_ipv6 = true

  # Configurar rede da VM.
  network {
    id      = 0
    model   = "virtio"
    bridge  = "vmbr0"
    macaddr = var.vm_macaddr
  }

  # Ignorar alterações nos atributos dos recursos.
  lifecycle {
    ignore_changes = [
      cicustom,
      sshkeys,
      network
    ]
  }
}

# Provisionar os scripts de configuração dentro da VM após criada.
resource "null_resource" "debian_nocloud" {
  depends_on = [proxmox_vm_qemu.debian_nocloud]
  
  connection {
    type        = "ssh"
    user        = var.vm_user
    private_key = file(var.private_key)
    host        = var.vm_ip #self.triggers.ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = var.config_motd_script_path
    destination = "/tmp/config_motd.sh"
  }

  provisioner "file" {
    source      = var.motd_zabbix_path
    destination = "/tmp/motd_zabbix"
  }

  provisioner "file" {
    source      = var.docker_compose_path
    destination = "/tmp/docker-compose.yml"
  }

  # Executar comandos remotos na VM após sua criação.
  provisioner "remote-exec" {
    inline = [
      # Instalar Docker do repositório oficial se ainda não existir.
      "if ! command -v docker >/dev/null 2>&1; then",
      "sudo apt update",
      "sudo apt install -y ca-certificates curl gnupg lsb-release",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "fi",

      # Executar script e o docker compose.
      "sudo chmod +x /tmp/config_motd.sh",
      "sudo bash /tmp/config_motd.sh",
      "sudo mkdir -p /root/docker_zabbix",
      "sudo mv /tmp/docker-compose.yml /root/docker_zabbix/docker-compose.yml",
      "sudo docker volume create --name zabbix_mysql_data",
      "sudo docker compose -f /root/docker_zabbix/docker-compose.yml up -d"
    ]
  }
}
