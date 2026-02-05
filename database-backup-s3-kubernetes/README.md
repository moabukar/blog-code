# Database Backup to S3 with Kubernetes CronJobs

Production-ready database backup system using Kubernetes CronJobs, PostgreSQL, and S3.

📖 **Blog Post:** [Database Backup to S3 with Kubernetes CronJobs](https://moabukar.co.uk/blog/database-backup-s3-kubernetes)

## Overview

Automated database backups using Kubernetes CronJob that streams PostgreSQL backups directly to S3, with a complete local testing environment using KIND and LocalStack.

```
+-------------+     +-------------+     +-------------+
|  PostgreSQL |---->|  K8s CronJob|---->|     S3      |
|   (source)  |     |  (pg_dump)  |     |  (storage)  |
+-------------+     +-------------+     +-------------+
```

## Files

```
.
├── Makefile                    # Build and test automation
├── docker-compose.yml          # LocalStack configuration
├── kind-config.yaml            # KIND cluster setup
├── postgres-deployment.yaml    # PostgreSQL deployments
├── backup-cronjob.yaml         # CronJob definition
├── secrets.yaml                # Secrets for testing
├── setup-localstack.sh         # S3 bucket setup
└── verify-backup.sh            # Backup verification
```

## Prerequisites

- Docker
- KIND (`brew install kind`)
- kubectl (`brew install kubectl`)
- awslocal (`pip install awscli-local`)

## Quick Start

```bash
# One-command setup and test
make quick

# Or step by step:
make setup          # Create KIND cluster + LocalStack + PostgreSQL
make test-working   # Run manual backup
make verify         # Verify backup integrity
```

## Make Targets

```
make setup           - Setup KIND cluster, LocalStack, and PostgreSQL
make test            - Run manual backup test
make test-working    - Run working backup test (simple job)
make verify          - Verify backup integrity and restore
make status          - Show current environment status
make logs            - Show logs from most recent backup job
make cleanup         - Remove all lab resources
make help            - Show all targets
```

## References

- [Kubernetes CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
- [KIND](https://kind.sigs.k8s.io/)
- [LocalStack](https://localstack.cloud/)
