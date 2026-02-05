# Self-Hosted GitLab on Kubernetes

Deploy GitLab on AKS with Azure SQL, Redis, and Blob Storage.

📖 **Blog Post:** [Self-Hosted GitLab on Kubernetes](https://moabukar.co.uk/blog/self-hosted-gitlab-kubernetes)

## Contents

```
self-hosted-gitlab-kubernetes/
├── helm/
│   ├── values.yaml               # Basic GitLab Helm config
│   └── values-production.yaml    # Full production config
├── terraform/
│   ├── main.tf                   # Basic infrastructure
│   └── azure-resources.tf        # Full Azure resources (PostgreSQL, Redis, Storage)
├── kubernetes/
│   ├── secrets-template.yaml     # Kubernetes secrets template
│   └── storage-class.yaml        # Azure Files Premium storage class
└── README.md
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         AKS Cluster                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  GitLab: Webservice, Sidekiq, Gitaly, Registry, Shell   │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
   Azure SQL            Azure Cache          Azure Blob
  (PostgreSQL)          (Redis)              (Storage)
```

## Prerequisites

- AKS cluster running
- kubectl configured
- Helm 3.x installed
- Domain name ready
- cert-manager installed

## Quick Start

### 1. Provision Azure Resources

```bash
cd terraform
terraform init
terraform apply
```

### 2. Create Kubernetes Secrets

```bash
kubectl create namespace gitlab

# PostgreSQL
kubectl create secret generic gitlab-postgres-secret \
  --namespace gitlab \
  --from-literal=password='YOUR_PASSWORD'

# Redis
kubectl create secret generic gitlab-redis-secret \
  --namespace gitlab \
  --from-literal=password='YOUR_REDIS_KEY'

# Azure Storage
kubectl create secret generic gitlab-azure-storage \
  --namespace gitlab \
  --from-literal=connection='provider: AzureRM
azure_storage_account_name: YOUR_ACCOUNT
azure_storage_access_key: YOUR_KEY'
```

### 3. Deploy GitLab

```bash
helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --values helm/values.yaml \
  --timeout 600s
```

### 4. Get Initial Password

```bash
kubectl get secret gitlab-gitlab-initial-root-password \
  --namespace gitlab \
  -ojsonpath='{.data.password}' | base64 -d
```

## Cost Comparison

| Item | GitLab.com Premium | Self-Hosted |
|------|-------------------|-------------|
| 50 users | ~$17,400/year | ~$3,600/year |
| Data location | GitLab servers | Your Azure |
| CI/CD limits | Rate limited | Unlimited |

## License

MIT
