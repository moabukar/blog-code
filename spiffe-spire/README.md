# SPIFFE/SPIRE Examples

Code examples for the blog post: [SPIFFE and SPIRE: Zero Trust Workload Identity](https://moabukar.co.uk/blog/spiffe-spire-workload-identity)

## Contents

```
spiffe-spire/
├── helm/                  # SPIRE Helm values
├── kubernetes/            # K8s manifests for workloads
└── examples/
    ├── go-server/         # mTLS server using go-spiffe
    └── go-client/         # mTLS client using go-spiffe
```

## Quick Start

### Deploy SPIRE

```bash
# Add Helm repo
helm repo add spiffe https://spiffe.github.io/helm-charts-hardened/
helm repo update

# Deploy SPIRE
kubectl create namespace spire-system
helm upgrade --install spire spiffe/spire \
  -n spire-system \
  -f helm/values.yaml \
  --wait
```

### Register Workloads

```bash
# Apply ClusterSPIFFEID
kubectl apply -f kubernetes/cluster-spiffe-id.yaml

# Or manually register
kubectl exec -n spire-system spire-server-0 -- \
  /opt/spire/bin/spire-server entry create \
    -spiffeID spiffe://example.com/ns/default/sa/api-server \
    -parentID spiffe://example.com/spire/agent/k8s_psat/cluster \
    -selector k8s:ns:default \
    -selector k8s:sa:api-server
```

### Deploy Example Workloads

```bash
kubectl apply -f kubernetes/server-deployment.yaml
kubectl apply -f kubernetes/client-deployment.yaml
```

## Testing mTLS

```bash
# Check server logs
kubectl logs -l app=mtls-server

# Check client logs (should show successful connection)
kubectl logs -l app=mtls-client
```

## Prerequisites

- Kubernetes cluster >= 1.28
- Helm >= 3.12
- kubectl configured

## License

MIT
