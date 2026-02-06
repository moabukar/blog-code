package main

import (
	"context"
	"io"
	"log"
	"net/http"
	"os"
	"time"

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

	serverURL := os.Getenv("SERVER_URL")
	if serverURL == "" {
		serverURL = "https://mtls-server:8443"
	}

	serverSPIFFEID := os.Getenv("SERVER_SPIFFE_ID")
	if serverSPIFFEID == "" {
		serverSPIFFEID = "spiffe://example.com/ns/default/sa/mtls-server"
	}

	intervalStr := os.Getenv("INTERVAL")
	interval := 10 * time.Second
	if intervalStr != "" {
		var err error
		interval, err = time.ParseDuration(intervalStr)
		if err != nil {
			log.Fatalf("Invalid INTERVAL: %v", err)
		}
	}

	// Create X509 source
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
	log.Printf("Client SPIFFE ID: %s", svid.ID.String())

	// Parse expected server SPIFFE ID
	serverID, err := spiffeid.FromString(serverSPIFFEID)
	if err != nil {
		log.Fatalf("Invalid server SPIFFE ID: %v", err)
	}

	// Create TLS config that:
	// 1. Presents our SVID as client certificate
	// 2. Validates server has expected SPIFFE ID
	tlsConfig := tlsconfig.MTLSClientConfig(source, source,
		tlsconfig.AuthorizeID(serverID),
	)

	// Create HTTP client
	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: tlsConfig,
		},
		Timeout: 10 * time.Second,
	}

	log.Printf("Starting requests to %s", serverURL)
	log.Printf("Expecting server SPIFFE ID: %s", serverID.String())

	// Make requests in a loop
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	for {
		makeRequest(client, serverURL+"/api/data")
		<-ticker.C
	}
}

func makeRequest(client *http.Client, url string) {
	resp, err := client.Get(url)
	if err != nil {
		log.Printf("Request failed: %v", err)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Failed to read response: %v", err)
		return
	}

	log.Printf("Response [%d]: %s", resp.StatusCode, string(body))
}
