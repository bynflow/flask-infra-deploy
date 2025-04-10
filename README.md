# Flask Infrastructure Deployment with Terraform, Ansible and Docker

Provisioning di un'infrastruttura scalabile su Hetzner Cloud con Terraform e configurazione automatica tramite Ansible. Deploy automatizzato di un'app Flask containerizzata con Docker.

## Stack Tecnologico

- **Terraform**: provisioning dell'infrastruttura Hetzner
- **Ansible**: configurazione automatizzata dei server
- **Docker**: containerizzazione dell'app Flask
- **Python/Flask**: applicazione demo
- *(In arrivo: HAProxy per load balancing)*

## Funzionalità

- Creazione dinamica di N server (default: 3)
- Deploy automatico di più container Flask per nodo
- Installazione di Docker e avvio container
- File di configurazione completamente parametrizzati
- Logging avanzato di Ansible e Terraform

## Sicurezza

- Nessun segreto/versionamento di credenziali
- `.gitignore` per escludere file sensibili
- File `terraform.tfvars.example` per configurazioni sicure

## Come usare il progetto

1. Clona il repository:
   ```bash
   git clone https://github.com/<tuo-username>/flask-infra-deploy.git
   cd flask-infra-deploy
