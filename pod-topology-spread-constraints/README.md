# Pod Topology Spread Constraints

Kubernetes examples for distributing pods across nodes, zones, and regions.

📖 **Blog Post:** [Pod Topology Spread Constraints](https://moabukar.co.uk/blog/pod-topology-spread-constraints)

## Contents

```
pod-topology-spread-constraints/
├── examples/
│   ├── basic-spread.yaml         # Spread across nodes
│   ├── zone-spread.yaml          # Spread across zones (HA)
│   ├── soft-spread.yaml          # Best-effort spreading
│   └── combined-with-affinity.yaml  # Full scheduling control
└── README.md
```

## Key Concepts

| Field | Description |
|-------|-------------|
| `maxSkew` | Max difference between most/least populated domains |
| `topologyKey` | Node label to group by (hostname, zone, region) |
| `whenUnsatisfiable` | `DoNotSchedule` (strict) or `ScheduleAnyway` (soft) |
| `labelSelector` | Which pods to count for distribution |

## Common Topology Keys

```yaml
kubernetes.io/hostname           # Per-node spread
topology.kubernetes.io/zone      # Per-AZ spread (HA)
topology.kubernetes.io/region    # Per-region spread (geo)
```

## Examples

### Even Distribution Across Nodes

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: web
```

### Zone + Node Spread

```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: web
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: web
```

## Quick Start

```bash
kubectl apply -f examples/basic-spread.yaml
kubectl get pods -o wide  # Check distribution
```

## License

MIT
