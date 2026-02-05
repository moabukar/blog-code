# Vertical Autoscaling for Aurora

Lambda-based vertical autoscaling for Aurora PostgreSQL/MySQL clusters.

📖 **Blog Post:** [Implementing Vertical Autoscaling for Aurora](https://moabukar.co.uk/blog/vertical-scaling-aurora)

## Architecture

```
CloudWatch Alarm (CPU > 80%)
        │
        ▼
    SNS Topic
        │
        ▼
  Alarm Lambda ──► Modify DB Instance
        │
        ▼
  RDS Event (modification complete)
        │
        ▼
  Event Lambda ──► Scale next instance / Failover
```

## Contents

```
vertical-scaling-aurora/
├── lambda/
│   └── alarm_handler.py     # Lambda triggered by CloudWatch alarm
├── terraform/
│   └── main.tf              # Infrastructure (alarms, SNS, Lambda, IAM)
└── README.md
```

## Instance Size Progression

```
db.r6g.large → db.r6g.xlarge → db.r6g.2xlarge → db.r6g.4xlarge → db.r6g.8xlarge
```

## Deployment

```bash
cd terraform

# Package Lambda
cd ../lambda && zip alarm_handler.zip alarm_handler.py && cd ../terraform

# Deploy
terraform init
terraform apply -var="cluster_identifier=my-aurora-cluster"
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `cluster_identifier` | required | Aurora cluster ID |
| `cpu_threshold_high` | 80 | CPU % to trigger scale up |
| `cpu_threshold_low` | 20 | CPU % to trigger scale down |

## How It Works

1. CloudWatch Alarm triggers when CPU > threshold
2. SNS delivers alarm to Lambda
3. Lambda identifies smallest reader instance
4. Lambda calls ModifyDBInstance with next size up
5. RDS Event subscription triggers on completion
6. Event Lambda scales remaining instances or triggers failover

## License

MIT
