# OPA Gatekeeper Examples

Code examples for: [OPA Gatekeeper: Policy as Code for Kubernetes](https://moabukar.co.uk/blog/opa-gatekeeper-kubernetes)

## Structure

```
opa-gatekeeper/
├── templates/      # ConstraintTemplate definitions
├── constraints/    # Constraint instances
├── mutations/      # Mutation policies
└── tests/          # Test resources
```

## Quick Start

```bash
# Install Gatekeeper
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm upgrade --install gatekeeper gatekeeper/gatekeeper \
  -n gatekeeper-system --create-namespace

# Apply templates first
kubectl apply -f templates/

# Then constraints
kubectl apply -f constraints/

# Optional: mutations
kubectl apply -f mutations/
```

## Testing

```bash
# Test a violating resource
kubectl apply -f tests/violation-deployment.yaml
# Should be rejected

# Test a compliant resource
kubectl apply -f tests/compliant-deployment.yaml
# Should succeed
```

## License

MIT
