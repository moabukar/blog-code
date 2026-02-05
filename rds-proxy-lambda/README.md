# RDS Proxy for Lambda - Connection Pooling

Solve the Lambda connection exhaustion problem with RDS Proxy.

📖 **Blog Post:** [RDS Proxy for Lambda - Solving the Connection Exhaustion Problem](https://moabukar.co.uk/blog/rds-proxy-lambda-connection-pooling)

## The Problem

```
Without RDS Proxy:
500 Lambda executions = 500 database connections = 💥 Connection exhausted

With RDS Proxy:
500 Lambda executions = 50 pooled connections = ✓ Scales
```

## Architecture

```
┌──────────────┐     ┌───────────────┐     ┌──────────┐
│   Lambda     │────►│   RDS Proxy   │────►│   RDS    │
│ (many calls) │     │ (connection   │     │ (fewer   │
│              │     │    pool)      │     │  conns)  │
└──────────────┘     └───────────────┘     └──────────┘
       │                    │
       │ IAM Auth           │ Secrets Manager
       ▼                    ▼
```

## Contents

```
rds-proxy-lambda/
├── terraform/
│   ├── main.tf              # Provider and variables
│   ├── vpc.tf               # VPC and networking
│   ├── security-groups.tf   # Security groups
│   ├── rds.tf               # RDS PostgreSQL instance
│   ├── secrets.tf           # Secrets Manager
│   ├── rds-proxy.tf         # RDS Proxy configuration
│   ├── lambda.tf            # Lambda function
│   └── outputs.tf           # Useful outputs
├── lambda/
│   ├── index.py             # Lambda handler with IAM auth
│   └── requirements.txt     # Python dependencies
└── README.md
```

## Quick Start

### 1. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### 2. Build Lambda Layer (for psycopg2)

```bash
# On Amazon Linux 2 or in Docker
pip install psycopg2-binary -t python/
zip -r layer.zip python/
```

### 3. Test the Lambda

```bash
aws lambda invoke \
  --function-name api-handler-prod \
  --payload '{}' \
  response.json

cat response.json
```

## Key Configuration

### RDS Proxy Connection Pool

```hcl
connection_pool_config {
  connection_borrow_timeout    = 120   # Wait time for connection
  max_connections_percent      = 100   # % of RDS max_connections
  max_idle_connections_percent = 50    # Idle connections to keep
}
```

### IAM Authentication (Lambda → Proxy)

```python
token = client.generate_db_auth_token(
    DBHostname=os.environ['DB_PROXY_ENDPOINT'],
    Port=5432,
    DBUsername='dbadmin',
    Region='eu-west-1'
)

conn = psycopg2.connect(
    host=os.environ['DB_PROXY_ENDPOINT'],
    password=token,  # Token as password
    sslmode='require'
)
```

## Connection Pinning

Operations that pin connections (reduce pooling efficiency):

- Open transactions (until COMMIT/ROLLBACK)
- Temporary tables
- User-defined variables
- LOCK TABLES
- Large statements (>16KB)

**Best Practice:** Keep transactions short!

## Monitoring

Key CloudWatch metrics:

| Metric | Description |
|--------|-------------|
| `ClientConnections` | Lambda → Proxy connections |
| `DatabaseConnections` | Proxy → RDS connections |
| `DatabaseConnectionsBorrowLatency` | Time to get connection from pool |

## Pricing

~$0.015/hour per vCPU of target database

Example: db.t3.medium (2 vCPUs) ≈ $21.60/month

## When to Use

✅ **Use RDS Proxy:**
- High concurrency Lambda functions
- Connection exhaustion issues
- Need improved failover handling

❌ **Skip RDS Proxy:**
- Low concurrency (few requests/sec)
- Long-running transactions
- Cost-sensitive, no connection issues

## License

MIT
