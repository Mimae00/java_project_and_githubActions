# Java App with GitHub Actions, Docker, Kubernetes, Terraform & Ansible

A Spring Boot Java application demonstrating a full DevOps pipeline: containerization, CI/CD automation, orchestration, infrastructure provisioning, and configuration management.

## Architecture

```
                        ┌──────────────┐
   Developer  ───push──▶│ GitHub Repo  │
                        └──────┬───────┘
                               │ triggers
                        ┌──────▼───────┐
                        │GitHub Actions│  build → test → docker build → push to Docker Hub
                        └──────┬───────┘
                               │
              ┌────────────────┼────────────────┐
              ▼                                  ▼
     ┌─────────────────┐              ┌────────────────────┐
     │ Docker Compose   │              │ Kubernetes (k8s/)   │
     │ (local/demo)     │              │ deployment+service  │
     └─────────────────┘              └────────────────────┘

     ┌─────────────────────────────────────────────────────┐
     │ Terraform (terraform/) → provisions AWS EC2 + SG      │
     │              │                                        │
     │              ▼                                        │
     │ Ansible (ansible/) → installs Docker, deploys app     │
     └─────────────────────────────────────────────────────┘
```

## Tech Stack

- **App:** Java (Spring Boot), Gradle
- **Containerization:** Docker, Docker Compose
- **Reverse Proxy:** Nginx
- **CI/CD:** GitHub Actions
- **Orchestration:** Kubernetes
- **Infrastructure as Code:** Terraform (AWS)
- **Configuration Management:** Ansible

## Project Structure

```
.
├── .github/workflows/     # CI/CD pipeline (build, test, docker build & push)
├── src/                   # Application source code
├── Dockerfile             # Builds the Java app image
├── Dockerfile.nginx       # Builds the nginx reverse-proxy image
├── docker-compose.yml     # Local/demo multi-container setup (app + nginx)
├── nginx.conf             # Nginx config used in the docker-compose image
├── k8s/                   # Kubernetes manifests
│   ├── app-deployment.yaml
│   ├── app-service.yaml
│   ├── nginx-deployment.yaml
│   ├── nginx-service.yaml
│   ├── nginx-configmap.yaml
│   └── ingress.yaml
├── terraform/             # AWS infrastructure provisioning
│   ├── provider.tf
│   ├── ec2.tf
│   ├── variables.tf
│   └── outputs.tf
└── ansible/                # Server configuration & app deployment
    ├── ansible.cfg
    ├── inventory.ini.example
    └── playbook.yml
```

## CI/CD Pipeline (GitHub Actions)

On every push, the pipeline:
1. Builds and tests the Java app with Gradle
2. Builds the Docker images (`app`, `nginx`)
3. Runs a `docker compose up` smoke test
4. Pushes images to Docker Hub

## Running Locally with Docker Compose

```bash
docker compose up -d
```
The app is served through nginx on `http://localhost`. Nginx proxies requests to the `app` service internally on port 8080.

## Deploying to Kubernetes

```bash
kubectl apply -f k8s/
```
This creates the app and nginx deployments/services, plus an ingress routing `petclinic.local` to the nginx service.

## Provisioning Infrastructure with Terraform

Terraform provisions a single AWS EC2 instance (free-tier `t2.micro`) with a security group allowing SSH (restricted to your IP) and HTTP (public).

```bash
cd terraform
terraform init
terraform apply -var="key_name=<your-aws-keypair-name>" -var="my_ip_cidr=<your-ip>/32"
```

After apply, note the output:
```bash
terraform output instance_public_ip
```

## Configuring the Server with Ansible

Ansible takes the EC2 instance Terraform created and installs Docker, then deploys the app.

```bash
cd ansible
cp inventory.ini.example inventory.ini
# edit inventory.ini: set the public IP from terraform output, and your SSH key path

ansible-playbook playbook.yml
```

The playbook:
- Installs Docker and the Docker Compose plugin
- Adds `ec2-user` to the `docker` group
- Copies `docker-compose.yml` to the server
- Runs `docker compose up -d` to pull and start the containers

Once complete, the app is reachable at `http://<instance_public_ip>`.

## Division of Responsibility

- **Terraform** answers *"what infrastructure exists?"* — the EC2 instance, networking, security group.
- **Ansible** answers *"what's installed and running on it?"* — Docker, containers, app configuration.
- **Kubernetes** manifests are an alternative orchestration path for environments with a cluster already available (e.g. EKS, minikube), rather than a single EC2 host.
