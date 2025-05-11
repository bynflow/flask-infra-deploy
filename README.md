# Flask Infrastructure Deployment with Terraform, Ansible, Docker and HAProxy

This project provisions a scalable multi-node infrastructure on Hetzner Cloud using **Terraform**, and configures it with **Ansible** to deploy a **Flask** application in **Docker** containers across multiple virtual machines. An **HAProxy** instance is used to load balance HTTP requests to all running containers across nodes.

---

## 🛠 Tech Stack

- **Terraform** – Infrastructure provisioning on Hetzner Cloud
- **Ansible** – Configuration management and automated deployment
- **Docker** – Containerization of the Flask application
- **Python / Flask** – Sample web application
- **HAProxy** – Load balancing across multiple containers

---

## 🔍 Features

- Automatic provisioning of N VM instances (default: 3)
- Each VM hosts multiple Flask containers (default: 3 per VM)
- Fully automated Docker build and run process via Ansible
- HAProxy deployment on the first VM to balance traffic across all containers
- Dynamic inventory and HAProxy configuration based on real IPs and ports
- Public IP + container ID shown in the app response for debugging/test

---

## 🔐 Security

- SSH key authentication only – no password-based login
- Secrets and credentials excluded via `.gitignore`
- Example vars file (`terraform.tfvars.example`) provided for safe config

---

## ▶️ How to Use

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/flask-infra-deploy.git
cd flask-infra-deploy
```

### 2. Set up your variables

Copy the example file and fill in your real Hetzner API token and config:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit the variables as needed:
- `hcloud_token`
- `ssh_key_name`
- `count_x`, `image`, etc.

### 3. Deploy the infrastructure

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve
```

### 4. Access the application

Once deployed, the app is accessible at the **public IP of server-0** on port **80** (thanks to HAProxy). Example:

```
http://<public-ip-server-0>
```

You should see:
- A welcome message
- The container name (`flask_app_X`)
- The public IP from which it is being served

### 5. Test load balancing (optional)

Run a quick loop with curl to observe round-robin behavior:

```bash
for i in {{1..20}}; do curl -s http://<public-ip-server-0> | grep -E "container|Public IP"; sleep 0.5; done
```

---

## 📦 Directory Structure (Essential)

```
flask-infra-deploy/
├── ansible/
│   ├── playbook.yml
│   ├── haproxy.yml
│   ├── app/
│   │   ├── app.py
│   │   └── templates/
│   └── templates/
│       └── haproxy.cfg.j2
├── terraform/
│   ├── main.tf
│   └── terraform.tfvars.example
└── README.md
```

---

## 📌 Status

✅ Load Balancer implemented  
🔜 Next steps: CI/CD pipeline, TDD, monitoring, metrics/logs, Kubernetes migration

---

## 🧠 Author

This project is part of a practical DevOps learning path and portfolio development.

Author: Carlo Capobianchi (bynflow)  
Year: 2025



