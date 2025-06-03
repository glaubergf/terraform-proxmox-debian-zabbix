---
Projeto: terraform-proxmox-debian-zabbix
Descrição: Este projeto automatiza o provisionamento de um servidor Debian 12 (Bookworm) no Proxmox, utilizando Terraform e Cloud-Init, realizando a instalação do Zabbix via containers Docker.
Autor: Glauber GF (mcnd2)
Criado em: 18-04-2025
---

![Imagem](https://github.com/glaubergf/terraform-proxmox-debian-zabbix/blob/main/images/tf-pm-zabbix.png)

![Imagem](https://github.com/glaubergf/terraform-proxmox-debian-zabbix/blob/main/images/zabbix.png)

![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)

# Servidor Debian Zabbix (Docker)

## 📜 Sobre o Projeto

Este projeto provisiona automaticamente um servidor **Debian 12 (Bookworm)** no **Proxmox** utilizando **Terraform** com suporte a **Cloud-Init**, realizando toda a instalação, configuração e deploy do **Zabbix (Server, Web, Java Gateway e Agent)** em containers Docker.

## 🪄 O Projeto Realiza

- Download da imagem Debian noCloud.
- Criação da VM no Proxmox via QEMU.
- Configuração do sistema operacional via Cloud-Init.
- Instalação do Docker e configuração do Docker.
- Deploy dos containers do Zabbix.

## 🧩 Tecnologias Utilizadas

![Terraform](https://img.shields.io/badge/Terraform-623CE4?logo=terraform&logoColor=white&style=for-the-badge)
- [Terraform](https://developer.hashicorp.com/terraform) — Provisionamento de infraestrutura como código (IaC).
 ---
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?logo=proxmox&logoColor=white&style=for-the-badge)
- [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) — Hypervisor para virtualização.
---
![Cloud-Init](https://img.shields.io/badge/Cloud--Init-00ADEF?logo=cloud&logoColor=white&style=for-the-badge)
- [Cloud-Init](https://cloudinit.readthedocs.io/en/latest/) — Ferramenta de inicialização e configuração automatizada da VM.
---
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white&style=for-the-badge)
- [Debian 12 (Bookworm)](https://www.debian.org/) — Sistema operacional da VM.
---
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge)
- [Docker](https://www.docker.com/) — Containerização da aplicação Zabbix.
---
![Zabbix](https://img.shields.io/badge/Zabbix-CC0000?style=for-the-badge&logo=zabbix&logoColor=white)
- [Zabbix](https://www.zabbix.com) — Monitoramento de infraestrutura
---
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
- [MariaDB](https://mariadb.org) — Banco de dados relacional

## 🛠️ Pré-requisitos

- ✅ Proxmox VE com acesso à API.
- ✅ Usuário no Proxmox com permissão para criação de VMs.
- ✅ Terraform instalado (v1.5 ou superior).
- ✅ SSH habilitado no Proxmox.
- ✅ Permissões de rede e chaves SSH configuradas.

## 📂 Estrutura do Projeto

```
terraform-proxmox-debian-zabbix
├── configs
│   ├── cloud_config.yml
│   ├── config_motd.sh
│   ├── docker-compose.yml
│   ├── motd_zabbix
│   ├── network_config.yml
│   └── vm_template.sh
├── images
│   ├── docker_ps.png
│   ├── tf-pm-zabbix.png
│   └── zabbix.png
├── LICENSE
├── notes
│   └── art_ascii_to_modt.txt
├── output.tf
├── provider.tf
├── README.md
├── security
│   ├── proxmox_id_rsa
│   └── proxmox_id_rsa.pub
├── terraform.tfvars
├── variables.tf
└── vm_proxmox.tf
```
### 📄 Arquivos

- `provider.tf` → Provedor do Proxmox
- `vm_proxmox.tf` → Criação da VM, configuração da rede, execução dos scripts
- `variables.tf` → Definição de variáveis
- `terraform.tfvars` → Valores das variáveis (customização)
- `cloud_config.yml` → Configurações do Cloud-Init (usuário, pacotes, timezone, scripts)
- `network_config.yml` → Configuração de rede estática

## 🚀 Fluxo de Funcionamento

1. **Terraform Init:** Inicializa o Terraform e carrega os providers e módulos necessários.

2. **Download da imagem Debian noCloud:** Baixa a imagem Debian pré-configurada (noCloud) se ainda não estiver no Proxmox.

3. **Criação da VM no Proxmox:** Terraform cria uma VM no Proxmox com base nas variáveis definidas.

4. **Aplicação do Cloud-Init:** Injeta configuração automática na VM (rede, usuário, SSH, hostname, etc.).

5. **Configuração inicial da VM:** A VM é inicializada e aplica configurações básicas: acesso remoto, hostname, rede, etc.

6. **Instalação do Docker:** Scripts do Cloud-Init instalam Docker e Docker Compose na VM.

7. **Deploy dos containers Zabbix:** O Docker Compose sobe os containers do Zabbix e do banco MariaDB.

## 🛠️ Terraform

Ferramenta de IaC (Infrastructure as Code) que permite definir e gerenciar infraestrutura através de arquivos de configuração declarativos.

Saiba mais: [https://developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform)

## 🖥️ Proxmox VE

O Proxmox VE é um hipervisor bare-metal, robusto e completo, muito utilizado tanto em ambientes profissionais quanto em homelabs. É uma plataforma de virtualização open-source que permite gerenciar máquinas virtuais e containers de forma eficiente, com suporte a alta disponibilidade, backups, snapshots e uma interface web intuitiva.

Saiba mais: [https://www.proxmox.com/](https://www.proxmox.com/)

## 🐧 Debian

Distribuição Linux livre, estável e robusta. A imagem utilizada é baseada em **Debian noCloud**, que permite integração com Cloud-Init no Proxmox.

Saiba mais: [https://www.debian.org/](https://www.debian.org/)

### ☁️ Sobre a imagem Debian nocloud

Este projeto utiliza a imagem Debian nocloud por maior estabilidade no provisionamento via Terraform no Proxmox, evitando problemas recorrentes como **kernel panic** em outras versões (*generic*, *genericcloud*).

## ☁️ Cloud-Init

Ferramenta de provisionamento padrão de instâncias de nuvem. Permite configurar usuários, pacotes, rede, timezone, scripts e mais, tudo automaticamente na criação da VM.

Saiba mais: [https://cloudinit.readthedocs.io/](https://cloudinit.readthedocs.io/)

## 🐳 Docker

Plataforma que permite empacotar, distribuir e executar aplicações em containers de forma leve, portátil e isolada, facilitando a implantação e escalabilidade de serviços.

Saiba mais: [https://www.docker.com](https://www.docker.com)

## 📈 Zabbix

O Zabbix é uma poderosa plataforma de monitoramento de infraestrutura, redes, servidores, serviços, aplicações e recursos em nuvem.

Este deploy inclui:

- `zabbix-server-mysql`
- `zabbix-web-nginx-mysql`
- `zabbix-java-gateway`
- `zabbix-agent`
- `mysql-server` para persistência dos dados

Saiba mais: [https://www.zabbix.com/](https://www.zabbix.com/)

## ▶️ Execução do Projeto

1. Clone o repositório:

```bash
git clone https://github.com/glaubergf/terraform-proxmox-debian-zabbix.git
cd terraform-proxmox-debian-zabbix
```

2. Configure suas variáveis em `terraform.tfvars`.

3. Execute os comandos abaixo para iniciar, mostrar o que vai ser criado e aplicar o provisionamento:

```bash
terraform init
terraform plan
terraform apply
```

4. Para destruir toda a infraestrutura criada:

```bash
terraform destroy
```

✅ Use `--auto-approve` para evitar confirmações manuais.

## 🤝 Contribuições

Contribuições são bem-vindas!

## 📜 Licença

Este projeto está licenciado sob os termos da **[GNU General Public License v3](https://www.gnu.org/licenses/gpl-3.0.html)**.

### 🏛️ Aviso Legal

```
Copyright (c) 2025

Este programa é software livre: você pode redistribuí-lo e/ou modificá-lo
sob os termos da Licença Pública Geral GNU conforme publicada pela
Free Software Foundation, na versão 3 da Licença.

Este programa é distribuído na esperança de que seja útil,
mas SEM NENHUMA GARANTIA, nem mesmo a garantia implícita de
COMERCIALIZAÇÃO ou ADEQUAÇÃO A UM DETERMINADO FIM.

Veja a Licença Pública Geral GNU para mais detalhes.
```
