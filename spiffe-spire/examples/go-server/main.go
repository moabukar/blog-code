package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
)

func main() {
	ctx := context.Background()

	// Get configuration from environment
	socketPath := os.Getenv("SPIFFE_ENDPOINT_SOCKET")
	if socketPath == "" {
		socketPath = "unix:///run/spire/agent-sockets/spire-agent.sock"
	}

	listenAddr := os.Getenv("LISTEN_ADDR")
	if listenAddr == "" {
		listenAddr = ":8443"
	}

	allowedDomain := os.Getenv("ALLOWED_TRUST_DOMAIN")
	if allowedDomain == "" {
		allowedDomain = "example.com"
	}

	// Create X509 source - automatically fetches and renews SVIDs
	log.Printf("Connecting to SPIFFE Workload API at %s", socketPath)
	source, err := workloadapi.NewX509Source(ctx,
		workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath)),
	)
	if err != nil {
		log.Fatalf("Unable to create X509Source: %v", err)
	}
	defer source.Close()

	// Log our SPIFFE ID
	svid, err := source.GetX509SVID()
	if err != nil {
		log.Fatalf("Unable to get X509 SVID: %v", err)
	}
	log.Printf("Server SPIFFE ID: %s", svid.ID.String())

	// Create TLS config that:
	// 1. Presents our SVID as server certificate
	// 2. Requires client certificate (mTLS)
	// 3. Validates client is in our trust domain
	tlsConfig := tlsconfig.MTLSServerConfig(source, source,
		tlsconfig.AuthorizeMemberOf(spiffeid.RequireTrustDomainFromString(allowedDomain)),
	)

	// HTTP handlers
	mux := http.NewServeMux()

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
	})

	mux.HandleFunc("/api/data", func(w http.ResponseWriter, r *http.Request) {
		// Extract client SPIFFE ID from TLS connection
		var clientID string
		if r.TLS != nil && len(r.TLS.PeerCertificates) > 0 {
			id, err := spiffeid.FromURI(r.TLS.PeerCertificates[0].URIs[0])
			if err == nil {
				clientID = id.String()
			}
		}

		log.Printf("Request from client: %s", clientID)

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"message":   "Hello from mTLS server",
			"client_id": clientID,
			"server_id": svid.ID.String(),
		})
	})

	mux.HandleFunc("/api/whoami", func(w http.ResponseWriter, r *http.Request) {
		var clientID string
		if r.TLS != nil && len(r.TLS.PeerCertificates) > 0 {
			id, err := spiffeid.FromURI(r.TLS.PeerCertificates[0].URIs[0])
			if err == nil {
				clientID = id.String()
			}
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"your_spiffe_id": clientID,
		})
	})

	// Start server
	server := &http.Server{
		Addr:      listenAddr,
		TLSConfig: tlsConfig,
		Handler:   mux,
	}

	log.Printf("Starting mTLS server on %s", listenAddr)
	log.Printf("Accepting clients from trust domain: %s", allowedDomain)
	log.Fatal(server.ListenAndServeTLS("", ""))
}
