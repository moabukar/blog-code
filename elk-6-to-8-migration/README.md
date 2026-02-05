# ELK Stack Migration: 6.x to 8.x

Scripts and configuration for migrating Elasticsearch, Logstash, and Kibana from 6.x to 8.x.

📖 **Blog Post:** [ELK Stack Migration: From 6.x to 8.x](https://moabukar.co.uk/blog/elk-6-to-8-migration)

## Upgrade Path

**Critical:** You cannot skip major versions.

```
6.x → 6.8 (latest) → 7.17 (latest 7.x) → 8.x
```

## Contents

```
elk-6-to-8-migration/
├── scripts/
│   ├── pre-upgrade-check.sh    # Check cluster readiness
│   ├── backup-snapshot.sh      # Create snapshot backup
│   └── reindex-5x-indices.sh   # Reindex 5.x indices
├── config/
│   └── elasticsearch-8.yml     # Sample ES 8.x config
└── README.md
```

## Quick Start

```bash
# Set your ES host
export ES_HOST="localhost:9200"

# 1. Check cluster readiness
./scripts/pre-upgrade-check.sh

# 2. Create backup
./scripts/backup-snapshot.sh

# 3. Reindex any 5.x indices (required before 7.x)
./scripts/reindex-5x-indices.sh
```

## Index Compatibility

| ES Version | Can Read Indices From |
|------------|----------------------|
| 6.x | 5.x, 6.x |
| 7.x | 6.x, 7.x |
| 8.x | 7.x, 8.x |

## Key Breaking Changes

### 6.x → 7.x
- Types removed (only `_doc`)
- `_all` field disabled by default
- Security enabled by default

### 7.x → 8.x
- Security mandatory
- TLS required
- Java 17+ required
- Many deprecated APIs removed

## License

MIT
