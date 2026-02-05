.PHONY: ci ci-push ci-pr ci-debug ci-dry ci-test ci-build

# Run CI workflow locally
ci:
	act push

# Run PR workflow
ci-pr:
	act pull_request

# Run with verbose output
ci-debug:
	act -v

# Dry run
ci-dry:
	act -n

# Specific job
ci-test:
	act -j test

ci-build:
	act -j build

# List available jobs
ci-list:
	act -l
