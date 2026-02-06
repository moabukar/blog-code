package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
)

// User represents the authenticated user from IAP headers
type User struct {
	Email  string   `json:"email"`
	Groups []string `json:"groups"`
}

// getUserFromHeaders extracts user identity from IAP-injected headers
func getUserFromHeaders(r *http.Request) *User {
	// Try different header formats (Pomerium, OAuth2-Proxy, GCP IAP)
	email := r.Header.Get("X-Forwarded-Email")
	if email == "" {
		email = r.Header.Get("X-Auth-Request-Email")
	}
	if email == "" {
		email = r.Header.Get("X-Goog-Authenticated-User-Email")
		// GCP IAP format: "accounts.google.com:user@example.com"
		if strings.Contains(email, ":") {
			parts := strings.SplitN(email, ":", 2)
			if len(parts) == 2 {
				email = parts[1]
			}
		}
	}

	if email == "" {
		return nil
	}

	// Parse groups
	groups := r.Header.Get("X-Forwarded-Groups")
	if groups == "" {
		groups = r.Header.Get("X-Auth-Request-Groups")
	}

	var groupList []string
	if groups != "" {
		groupList = strings.Split(groups, ",")
		// Trim whitespace from each group
		for i, g := range groupList {
			groupList[i] = strings.TrimSpace(g)
		}
	}

	return &User{
		Email:  email,
		Groups: groupList,
	}
}

// requireAuth middleware ensures the request has valid IAP headers
func requireAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := getUserFromHeaders(r)
		if user == nil {
			http.Error(w, `{"error": "Unauthorized"}`, http.StatusUnauthorized)
			return
		}

		log.Printf("Request from user: %s, groups: %v, path: %s", user.Email, user.Groups, r.URL.Path)
		next(w, r)
	}
}

// requireGroup middleware ensures the user belongs to a specific group
func requireGroup(group string, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := getUserFromHeaders(r)
		if user == nil {
			http.Error(w, `{"error": "Unauthorized"}`, http.StatusUnauthorized)
			return
		}

		for _, g := range user.Groups {
			if g == group {
				next(w, r)
				return
			}
		}

		log.Printf("Access denied for user %s: requires group %s, has %v", user.Email, group, user.Groups)
		http.Error(w, `{"error": "Forbidden: requires group `+group+`"}`, http.StatusForbidden)
	}
}

// requireAnyGroup middleware ensures the user belongs to at least one of the specified groups
func requireAnyGroup(groups []string, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		user := getUserFromHeaders(r)
		if user == nil {
			http.Error(w, `{"error": "Unauthorized"}`, http.StatusUnauthorized)
			return
		}

		for _, userGroup := range user.Groups {
			for _, requiredGroup := range groups {
				if userGroup == requiredGroup {
					next(w, r)
					return
				}
			}
		}

		log.Printf("Access denied for user %s: requires one of %v, has %v", user.Email, groups, user.Groups)
		http.Error(w, `{"error": "Forbidden"}`, http.StatusForbidden)
	}
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Health check (no auth required)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
	})

	// Public endpoint (shows if user is authenticated)
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		user := getUserFromHeaders(r)
		if user != nil {
			json.NewEncoder(w).Encode(map[string]interface{}{
				"message":       "Welcome!",
				"authenticated": true,
				"user":          user,
			})
		} else {
			json.NewEncoder(w).Encode(map[string]interface{}{
				"message":       "Welcome! (not authenticated)",
				"authenticated": false,
			})
		}
	})

	// User info endpoint (requires authentication)
	http.HandleFunc("/api/me", requireAuth(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		user := getUserFromHeaders(r)
		json.NewEncoder(w).Encode(user)
	}))

	// Data endpoint (requires authentication)
	http.HandleFunc("/api/data", requireAuth(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		user := getUserFromHeaders(r)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"data":      []string{"item1", "item2", "item3"},
			"accessed_by": user.Email,
		})
	}))

	// Admin endpoint (requires admin group)
	http.HandleFunc("/api/admin", requireGroup("admin", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		user := getUserFromHeaders(r)
		json.NewEncoder(w).Encode(map[string]interface{}{
			"message": "Admin-only endpoint",
			"admin":   user.Email,
		})
	}))

	// Engineering endpoint (requires engineering or platform group)
	http.HandleFunc("/api/engineering", requireAnyGroup(
		[]string{"engineering", "platform-team", "sre"},
		func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			user := getUserFromHeaders(r)
			json.NewEncoder(w).Encode(map[string]interface{}{
				"message": "Engineering data",
				"user":    user.Email,
				"groups":  user.Groups,
			})
		},
	))

	// Debug endpoint (shows all headers - useful for troubleshooting)
	http.HandleFunc("/debug/headers", requireAuth(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		headers := make(map[string]string)
		for name, values := range r.Header {
			// Filter to only show relevant headers
			lowerName := strings.ToLower(name)
			if strings.HasPrefix(lowerName, "x-forwarded") ||
				strings.HasPrefix(lowerName, "x-auth") ||
				strings.HasPrefix(lowerName, "x-goog") {
				headers[name] = strings.Join(values, ", ")
			}
		}
		json.NewEncoder(w).Encode(headers)
	}))

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
