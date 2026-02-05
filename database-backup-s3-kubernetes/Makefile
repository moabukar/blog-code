.PHONY: help setup cleanup test test-working verify status logs logs-follow test-db test-s3 e2e quick

# Default target
help:
	@echo "RDS Backup Test Makefile"
	@echo "========================"
	@echo ""
	@echo "Available targets:"
	@echo "  setup           - Setup KIND cluster, LocalStack, and PostgreSQL"
	@echo "  test            - Run manual backup test (cronjob-based)"
	@echo "  test-working    - Run working backup test (simple job)"
	@echo "  verify          - Verify backup integrity and restore"
	@echo "  status          - Show current environment status"
	@echo "  logs            - Show logs from most recent backup job"
	@echo "  logs-follow     - Follow logs of running backup job"
	@echo "  test-db         - Test database connectivity"
	@echo "  test-s3         - Test LocalStack S3 connectivity"
	@echo "  e2e             - Complete end-to-end test"
	@echo "  quick           - Quick test cycle (cleanup -> setup -> test -> verify)"
	@echo "  cleanup         - Remove all lab resources"
	@echo "  help            - Show this help"
	@echo ""
	@echo "Quick start: make setup && make test-working && make verify"

# Setup complete environment
setup:
	@echo "=== Setting up test environment ==="
	docker-compose up -d
	@echo "Waiting for LocalStack..."
	@sleep 5
	./setup-localstack.sh
	kind create cluster --config kind-config.yaml || true
	kubectl apply -f postgres-deployment.yaml
	kubectl apply -f secrets.yaml
	@echo "Waiting for PostgreSQL..."
	kubectl wait --for=condition=available deployment/postgres-replica --timeout=120s
	@echo "=== Setup complete ==="

# Run backup test
test:
	kubectl create job --from=cronjob/rds-backup-cronjob manual-backup-$$(date +%s) || true
	@echo "Watching backup job..."
	kubectl get jobs -w

test-working:
	kubectl delete job manual-backup 2>/dev/null || true
	kubectl apply -f backup-cronjob.yaml
	kubectl create job --from=cronjob/rds-backup-cronjob manual-backup
	kubectl wait --for=condition=complete job/manual-backup --timeout=300s
	kubectl logs job/manual-backup

# Verify backup
verify:
	./verify-backup.sh

# Show status
status:
	@echo "=== KIND Cluster ==="
	kind get clusters
	@echo ""
	@echo "=== Pods ==="
	kubectl get pods
	@echo ""
	@echo "=== CronJobs ==="
	kubectl get cronjobs
	@echo ""
	@echo "=== Jobs ==="
	kubectl get jobs
	@echo ""
	@echo "=== LocalStack ==="
	curl -s http://localhost:4566/_localstack/health | jq . || echo "LocalStack not running"

# Show logs
logs:
	kubectl logs $$(kubectl get pods --sort-by=.metadata.creationTimestamp -l job-name -o jsonpath='{.items[-1].metadata.name}')

logs-follow:
	kubectl logs -f $$(kubectl get pods -l job-name -o jsonpath='{.items[0].metadata.name}')

# Test database
test-db:
	kubectl exec deployment/postgres-replica -- pg_isready -h localhost -p 5432 -U root

# Test S3
test-s3:
	@export AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1 && \
	awslocal s3 ls

# End-to-end test
e2e: cleanup setup test-working verify
	@echo "=== E2E Test Complete ==="

# Quick test cycle
quick: cleanup setup test-working verify

# Cleanup
cleanup:
	kind delete cluster --name backup-test || true
	docker-compose down -v || true
	rm -f test-restore.dump lifecycle-policy.json
	@echo "=== Cleanup complete ==="
