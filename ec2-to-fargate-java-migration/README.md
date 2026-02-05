# EC2 to Fargate Java Migration

Complete guide to containerising a Java JAR and deploying to ECS Fargate.

📖 **Blog Post:** [Migrating Java from EC2 to ECS Fargate](https://moabukar.co.uk/blog/ec2-to-fargate-java-migration)

## Contents

```
ec2-to-fargate-java-migration/
├── docker/
│   └── Dockerfile            # Production-ready Java container
├── ecs/
│   └── task-definition.json  # ECS task definition template
├── terraform/
│   └── main.tf               # ECS infrastructure
└── README.md
```

## Quick Start

### 1. Build Docker Image

```bash
# Build
docker build -f docker/Dockerfile -t myapp:latest .

# Test locally
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=local \
  -e DB_HOST=host.docker.internal \
  myapp:latest

# Verify
curl http://localhost:8080/actuator/health
```

### 2. Push to ECR

```bash
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com

docker tag myapp:latest ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/myapp:latest
docker push ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/myapp:latest
```

### 3. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

## JVM Best Practices for Containers

```dockerfile
# Let JVM respect container memory limits
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
```

## Secrets Management

Use AWS Secrets Manager instead of environment variables for sensitive data:

```json
{
  "secrets": [
    {
      "name": "DB_PASSWORD",
      "valueFrom": "arn:aws:secretsmanager:region:account:secret:myapp/db"
    }
  ]
}
```

## License

MIT
