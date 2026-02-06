# eBPF Security Examples

Code examples for: [eBPF for Security: Kernel-Level Observability](https://moabukar.co.uk/blog/ebpf-security-deep-dive)

## Contents

```
ebpf-security/
├── cilium/         # Cilium network policies
├── falco/          # Falco rules and config
└── tetragon/       # Tetragon tracing policies
```

## Quick Start

### Cilium

```bash
cilium install --version 1.15.0
kubectl apply -f cilium/
```

### Falco

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm upgrade --install falco falcosecurity/falco \
  -n falco --create-namespace \
  -f falco/values.yaml
```

### Tetragon

```bash
helm repo add cilium https://helm.cilium.io
helm upgrade --install tetragon cilium/tetragon -n kube-system
kubectl apply -f tetragon/
```

## License

MIT
