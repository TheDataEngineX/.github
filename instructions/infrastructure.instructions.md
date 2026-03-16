---
applyTo: "terraform/**,helm/**,ansible/**,Dockerfile,docker-compose*.yml,monitoring/**"
---

# Infrastructure Standards

## Terraform

- Modules must have `variables.tf`, `outputs.tf`, `main.tf` — no monolithic files
- Variables must have `description` and `type`
- Sensitive variables (tokens, passwords) must have `sensitive = true`
- Remote state only — never local state for shared resources
- Run `terraform fmt` before committing — CI enforces `terraform fmt -check`

## Helm

- Every chart must pass `helm lint` — CI enforces this
- `values.yaml` must document every key with a comment
- Image tags must be explicit — never `latest` in production values
- Resource requests and limits required on every container
- Liveness and readiness probes required on every deployment
- Secrets must reference Kubernetes `Secret` objects — never inline in `values.yaml`

## Docker

- Multi-stage builds: builder stage → minimal runtime stage
- Base image: `python:3.12-slim`
- Non-root user: `RUN useradd -m dex && USER dex`
- No secrets in `ENV` or `ARG`
- `.dockerignore` must exclude `.venv`, `__pycache__`, `.git`, `.env`

## docker-compose

- Named volumes — not bind mounts for persistent data
- Health checks on every service with `interval`, `timeout`, `retries`
- `restart: unless-stopped` on all services
- Passwords as env vars from `.env` — never hardcoded
- Explicit named network

## Monitoring

- Alert rules must have `severity` label: `page` or `warning`
- Grafana dashboards provisioned via `grafana/provisioning/` — not manually created
- Every service must expose `/metrics` before being added to scrape config

## Ansible

- Idempotent tasks only
- `become: true` only where root is genuinely required
- Vault-encrypt all secrets
- Tag every task: `tags: [install, configure, start]`

## Checklist

- [ ] Terraform: `fmt` clean, no local state, sensitive vars marked
- [ ] Helm: lint passes, no `latest` tag, resource limits, probes configured
- [ ] Docker: non-root user, multi-stage, no secrets in ENV/ARG
- [ ] docker-compose: health checks, named volumes, explicit network
- [ ] Monitoring: severity labels, dashboards provisioned
- [ ] No hardcoded credentials anywhere
