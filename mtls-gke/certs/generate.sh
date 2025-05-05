#!/bin/bash
mkdir -p certs && cd certs

# CA
openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
  -subj "/CN=MyCA" -keyout ca.key -out ca.crt

# Server
openssl req -new -newkey rsa:2048 -nodes -keyout server.key \
  -subj "/CN=httpbin.local" -out server.csr
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt -days 365

# Client
openssl req -new -newkey rsa:2048 -nodes -keyout client.key \
  -subj "/CN=test-client" -out client.csr
openssl x509 -req -in client.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out client.crt -days 365
