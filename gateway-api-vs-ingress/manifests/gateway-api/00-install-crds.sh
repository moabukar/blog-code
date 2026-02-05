#!/bin/bash
# Install Gateway API CRDs
# Run this before deploying any Gateway API resources

set -e

GATEWAY_API_VERSION="${GATEWAY_API_VERSION:-v1.2.0}"

echo "Installing Gateway API CRDs version: ${GATEWAY_API_VERSION}"

# Standard channel - stable resources (Gateway, GatewayClass, HTTPRoute, GRPCRoute)
kubectl apply -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

# Uncomment for experimental resources (TLSRoute, TCPRoute, UDPRoute)
# kubectl apply -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/experimental-install.yaml"

echo "Gateway API CRDs installed successfully"

# Verify installation
echo ""
echo "Installed CRDs:"
kubectl get crds | grep gateway.networking.k8s.io
