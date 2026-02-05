# Pod Security Standards Enforcement

Companion code for: [Pod Security Standards Enforcement](https://moabukar.co.uk/blog/pod-security-standards-enforcement)

## Quick Start

```bash
# Label namespace with restricted policy
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest

# Test a pod
kubectl apply -f manifests/compliant-pod.yaml -n production
```

## Contents

- `manifests/namespaces/` - Namespace configurations with PSS labels
- `manifests/pods/` - Example compliant pods for each profile
- `manifests/deployments/` - Production-ready deployment templates

## Profiles

| Profile | Use Case |
|---------|----------|
| Privileged | System components, CNI, CSI |
| Baseline | Most workloads |
| Restricted | Security-critical apps |

## License

MIT
