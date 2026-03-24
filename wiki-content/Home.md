# DEX

> Core framework for data engineering, ML, and observability.

[![CI](https://github.com/TheDataEngineX/DEX/actions/workflows/ci.yml/badge.svg?branch=dev)](https://github.com/TheDataEngineX/DEX/actions/workflows/ci.yml)
[![PyPI](https://img.shields.io/pypi/v/dataenginex)](https://pypi.org/project/dataenginex/)
[![Python 3.13+](https://img.shields.io/badge/python-3.13+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Coverage](https://img.shields.io/badge/coverage-94%25-brightgreen)](https://github.com/TheDataEngineX/DEX)

## What is DEX?

A production-focused Python framework for data engineering — medallion architecture, ML lifecycle management, and enterprise observability out of the box.

`dataenginex` is the core library. It is the only published package — applications and ecosystem repos are built on top of it.

## Quick Start

```bash
# Install core (no web framework dependencies)
pip install dataenginex

# With FastAPI, middleware, auth, health checks
pip install dataenginex[api]

# With cloud storage backends
pip install dataenginex[s3]      # AWS S3 via boto3
pip install dataenginex[gcs]     # Google Cloud Storage
pip install dataenginex[bq]      # Google BigQuery
pip install dataenginex[cloud]   # All cloud storage (S3 + GCS)

# Everything
pip install dataenginex[all]
```

```bash
# Clone and develop
git clone https://github.com/TheDataEngineX/DEX && cd DEX
uv run poe setup    # install deps + pre-commit hooks
uv run poe dev      # dev server → http://localhost:17000
uv run poe test     # run tests
```

## Quick Usage

```python
# Core — always available
from dataenginex.core import MedallionArchitecture, QualityGate
from dataenginex.data import SchemaRegistry
from dataenginex.ml import ModelRegistry

# API — requires pip install dataenginex[api]
from dataenginex.api import HealthChecker, AuthMiddleware, paginate
from dataenginex.middleware import configure_logging, configure_tracing

# Storage — requires the relevant extra
from dataenginex.lakehouse import JsonStorage, get_storage
storage = get_storage("file://./data")       # always works
storage = get_storage("s3://my-bucket")      # requires [s3]
storage = get_storage("gs://my-bucket")      # requires [gcs]
storage = get_storage("bq://my-project/ds")  # requires [bq]
```

## Module Overview

| Module | Requires Extra | Description |
|--------|----------------|-------------|
| `dataenginex.core` | — | Medallion architecture, schemas, quality gates, validators |
| `dataenginex.data` | — | Schema registry, data contracts, catalog |
| `dataenginex.lakehouse` | optional `[s3]` `[gcs]` `[bq]` | Storage backends (JSON, Parquet, S3, GCS, BigQuery), catalog, partitioning |
| `dataenginex.warehouse` | — | Warehouse layers, lineage tracking |
| `dataenginex.ml` | — | Model registry, vectorstore, LLM adapters, drift detection |
| `dataenginex.api` | `[api]` | Auth (JWT), health checks, error handling, pagination, rate limiting |
| `dataenginex.middleware` | `[api]` | Structured logging, Prometheus metrics, OpenTelemetry tracing |

## Plugin System

Extend the framework by implementing `DataEngineXPlugin` and registering an entry point:

```toml
# pyproject.toml
[project.entry-points."dataenginex.plugins"]
my_plugin = "my_package.plugin:MyPlugin"
```

```python
from dataenginex.plugins import discover, PluginRegistry

plugins = discover()          # auto-loads all installed plugins
registry = PluginRegistry()
for plugin in plugins:
    registry.register(plugin)

status = registry.health_check_all()
```

## Workspace

Part of the [DataEngineX](https://github.com/TheDataEngineX) ecosystem:

| Repo | Purpose | Port |
|------|---------|------|
| [DEX](https://github.com/TheDataEngineX/DEX) | Core framework (data + ML + AI) | 17000 |
| [dex-studio](https://github.com/TheDataEngineX/dex-studio) | Desktop UI | 7860 |
| [infradex](https://github.com/TheDataEngineX/infradex) | Infrastructure | — |

> **Note:** datadex, agentdex, and careerdex have been consolidated into [DEX](https://github.com/TheDataEngineX/DEX). Those repos are archived.

Full observability stack (Prometheus + Grafana + Jaeger): see [infradex](https://github.com/TheDataEngineX/infradex) `docker-compose.monitoring.yml`.

## Pages

- [[Architecture]] — Medallion pipeline, module graph, extras
- [[ML-Guide]] — ModelRegistry, RAG, LLM providers, drift detection
- [[Development]] — Build, test, and run commands
- [[Changelog]] — Recent version history

---

**License**: MIT | **Python**: 3.13+
