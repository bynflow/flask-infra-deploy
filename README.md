# Flask Infrastructure Deployment with Terraform, Ansible, Docker and HAProxy

This project provisions a scalable multi-node infrastructure on Hetzner Cloud using **Terraform**, and configures it with **Ansible** to deploy a **Flask** application in **Docker** containers across multiple virtual machines. An **HAProxy** instance is used to load balance HTTP/HTTPS requests to all running containers across nodes.

## Tech Stack

* **Terraform** – Infrastructure provisioning on Hetzner Cloud
* **Ansible** – Configuration management and automated deployment
* **Docker** – Containerization of the Flask application
* **Python / Flask** – Sample web application
* **HAProxy** – Reverse proxy and load balancer with HTTP/HTTPS support

## Features

* Automatic provisioning of N VM instances (default: 3)
* Each VM hosts multiple Flask containers (default: 3 per VM)
* Fully automated Docker build and deployment via Ansible
* HAProxy deployed on the first VM to balance HTTP and HTTPS traffic
* Self-signed SSL certificate generated automatically on deployment
* Dynamic inventory and HAProxy configuration based on public IPs and ports
* Each container exposes both the container name and public IP for traceability

## Security

* SSH key authentication only (no passwords)
* HTTPS enabled with self-signed certificate
* Certificate and private key stored securely in `/etc/ssl/haproxy`
* Git-ignored sensitive files and keys
* Sample vars file (`terraform.tfvars.example`) for secure configuration

## How to Use

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/flask-infra-deploy.git
cd flask-infra-deploy
```

### 2. Configure your Hetzner credentials and variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Then edit:

* `hcloud_token`
* `ssh_key_name`
* `count_x`, `image`, etc.

### 3. Deploy the infrastructure and application

```bash
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve
```

### 4. Access the application

Once deployed, HAProxy listens on both **HTTP (port 80)** and **HTTPS (port 443)** of the public IP of **server-0**.

#### HTTP:

```
http://<public-ip-server-0>
```

#### HTTPS (with self-signed certificate):

```
https://<public-ip-server-0>
```

Your browser will display a certificate warning. Accept it to proceed.

The page will display:

* Input form to calculate square of a number
* The container name (e.g., `flask_app_X`)
* The public IP that served the response

### 5. Test round-robin load balancing (optional)

To verify that HAProxy correctly distributes incoming traffic among the Flask containers, you can run the following test from any machine:

```bash
for i in {1..20}; do \
  curl -k -s -X POST https://<public-ip-server-0>/ -d "number=5" \
  | grep -E "container|Public IP"; \
  sleep 0.5; \
done
```

Replace `<public-ip-server-0>` with the actual public IP address of the HAProxy node (usually `server-0`). The `-k` flag skips SSL certificate validation due to the use of a self-signed certificate.

This will simulate 20 POST requests with the number `5` and output the responding container and its public IP, demonstrating the round-robin distribution.

## Directory Structure (Essential)

```
flask-infra-deploy/
├── ansible/
│   ├── deploy_flask_app.yml
│   ├── haproxy.yml
│   ├── tasks/
│   │   └── generate_selfsigned_cert.yml
│   ├── app/
│   │   ├── app.py
│   │   └── templates/
│   │       ├── number_square.html
│   │       └── result.html
│   └── templates/
│       └── haproxy.cfg.j2
├── terraform/
│   ├── main.tf
│   ├── terraform.tfvars.example
│   └── ansible_hosts.tmpl
└── README.md
```

## Status

* Infrastructure as Code and automated deployment: complete
* HTTPS with HAProxy (self-signed): implemented
* Load balancing across all backend containers: working

## Next Steps (future milestones)

* CI/CD pipeline with GitHub Actions
* Test-driven development (TDD)
* Infrastructure testing (Ansible/Terraform)
* Observability: metrics, logs, tracing
* Kubernetes migration

## Author

**Carlo Capobianchi** (bynflow)
Year: 2025

This project is part of a structured DevOps learning path and professional portfolio.
