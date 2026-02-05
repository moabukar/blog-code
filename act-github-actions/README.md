# Test GitHub Actions Locally with Act

Run GitHub Actions workflows locally using Docker for instant feedback.

📖 **Blog Post:** [Test GitHub Actions Locally with Act](https://moabukar.co.uk/blog/act-locally-test-github-actions)

## Contents

```
act-github-actions/
├── .actrc                    # Default act configuration
├── .secrets.example          # Template for secrets file
├── Makefile                  # Common act commands
└── examples/
    ├── ci.yml                # Basic CI workflow
    ├── matrix.yml            # Matrix strategy example
    └── services.yml          # Service containers example
```

## Quick Start

```bash
# Install act
brew install act  # macOS
# or
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash  # Linux

# Copy secrets template
cp .secrets.example .secrets
# Edit .secrets with your values

# Run default workflow
act

# Run specific event
act pull_request

# Dry run
act -n
```

## Common Commands

```bash
act                    # Run push event
act pull_request       # Run PR event
act -j build           # Run specific job
act -W .github/workflows/ci.yml  # Run specific workflow
act -n                 # Dry run
act -v                 # Verbose output
act -l                 # List jobs
```

## Configuration

Place `.actrc` in repo root or `~/.actrc`:

```bash
-P ubuntu-latest=catthehacker/ubuntu:act-22.04
--secret-file .secrets
--env-file .env
```

## License

MIT
