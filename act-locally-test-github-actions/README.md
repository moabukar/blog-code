# Test GitHub Actions Locally with Act

Run GitHub Actions workflows locally using Docker - stop pushing to test your workflows.

📖 **Blog Post:** [Test GitHub Actions Locally with Act](https://moabukar.co.uk/blog/act-locally-test-github-actions)

## Overview

Act lets you run GitHub Actions locally on your machine. Change workflow, run `act`, see results in seconds. No push required.

## Files

```
.
├── .actrc                    # Act configuration file
├── .secrets.example          # Template for secrets
├── Dockerfile.act            # Custom runner image
├── Makefile                  # Convenient make targets
└── .github/
    └── workflows/
        └── ci.yml            # Example CI workflow
```

## Quick Start

```bash
# Install act
brew install act  # macOS
# or
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash  # Linux

# Run the default event (push)
act

# Run a specific job
act -j build

# Dry run
act -n
```

## Configuration

1. Copy `.secrets.example` to `.secrets` and fill in your values
2. Adjust `.actrc` for your preferred runner image
3. Run `act` to test workflows locally

## Key Commands

```bash
act                    # Run default (push) event
act pull_request       # Run PR event
act -j build           # Run specific job
act -n                 # Dry run
act -v                 # Verbose output
act -l                 # List available jobs
act --reuse            # Reuse containers
```

## References

- [Act GitHub Repository](https://github.com/nektos/act)
- [Runner Images](https://github.com/catthehacker/docker_images)
