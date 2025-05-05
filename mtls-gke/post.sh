#!/bin/bash
PROJECT_ID=$(gcloud config get-value project)
REGION=us-central1
CLUSTER=mtls-demo

echo "[+] Getting GKE credentials..."
gcloud container clusters get-credentials $CLUSTER --region $REGION

echo "[+] Enabling Gateway API..."
gcloud container hub gateway-api enable
