# Architecture

## Medallion Data Pipeline

DEX implements the medallion (lakehouse) architecture as its core data processing pattern:

```
Raw Sources (APIs, files, streams)
         ↓
    BRONZE LAYER — Raw ingestion (Parquet)
         ↓  quality gate ≥ 75%
    SILVER LAYER — Cleaned & validated
         ↓  quality gate ≥ 90%
    GOLD LAYER — Enriched & aggregated
         ↓
  API / ML / Analytics
```

Each layer transition enforces a `QualityGate`. The gate is injectable — you can supply custom `scorer`, `required_fields`, and `uniqueness_key` arguments.

```python
from dataenginex.core import MedallionArchitecture, QualityGate

arch = MedallionArchitecture()
gate = QualityGate(
    scorer=my_scorer,
    required_fields=["id", "timestamp"],
    uniqueness_key="id",
)
```

## Module Dependency Graph

```
dataenginex.core          ← always available (pydantic, pyyaml, loguru)
dataenginex.data          ← always available
dataenginex.lakehouse     ← always available; cloud extras unlock backends
dataenginex.warehouse     ← always available
dataenginex.ml            ← always available
dataenginex.plugins       ← always available

dataenginex.api           ← requires [api] extra (FastAPI, uvicorn, structlog, OpenTelemetry)
dataenginex.middleware    ← requires [api] extra
dataenginex.dashboard     ← requires [dashboard] extra (Streamlit)
```

Key design decision (v0.6.0): FastAPI is **optional**. The core install ships only lightweight deps. API/middleware consumers must opt in with `pip install dataenginex[api]`.

## Optional Extras

| Extra | Unlocks | Key Deps |
|-------|---------|----------|
| `[api]` | `dataenginex.api`, `dataenginex.middleware` | FastAPI, uvicorn, structlog, OpenTelemetry |
| `[s3]` | S3 storage backend | boto3 |
| `[gcs]` | GCS storage backend | google-cloud-storage |
| `[bq]` | BigQuery storage backend | google-cloud-bigquery |
| `[cloud]` | S3 + GCS backends | boto3, google-cloud-storage |
| `[ml]` | `SentenceTransformerEmbedder` | sentence-transformers |
| `[notebook]` | Jupyter utilities | ipykernel |
| `[dashboard]` | Streamlit dashboard | streamlit |
| `[all]` | Everything above | — |

## Storage Backends

Storage is accessed via a unified `StorageBackend` ABC and a `get_storage(uri)` factory:

| URI Scheme | Backend | Extra Required |
|------------|---------|----------------|
| `file://` | `LocalParquetStorage` | — |
| `json://` | `JsonStorage` | — |
| `parquet://` | `ParquetStorage` | — |
| `s3://` | `S3Storage` | `[s3]` |
| `gs://` | `GCSStorage` | `[gcs]` |
| `bq://` | `BigQueryStorage` | `[bq]` |

All backends implement `read()`, `write()`, `list_objects(prefix)`, and `exists(path)`.

## API Architecture

The API module provides reusable primitives only — no route definitions ship with `dataenginex`. Applications (e.g. `careerdex.api.routers`) define their own routes.

Provided utilities:
- **Auth** — Pure-Python HS256 JWT (no pyjwt dependency)
- **Health checks** — `HealthChecker` for liveness/readiness probes
- **Pagination** — Cursor-based `paginate()` helper
- **Rate limiting** — Configurable middleware
- **Error handling** — Structured HTTP error responses

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Python 3.12+ |
| Package Manager | uv + Hatchling |
| Web Framework | FastAPI + Uvicorn (optional `[api]`) |
| Orchestration | Apache Airflow |
| Big Data | PySpark |
| Code Quality | Ruff + mypy (strict) |
| Testing | pytest + coverage (94%) |
| Observability | Prometheus, Grafana, Jaeger (OpenTelemetry) |
| Containers | Docker (multi-stage, non-root) |
| Kubernetes | K3s + ArgoCD (GitOps) |
| CI/CD | GitHub Actions |

## Project Structure

```
DEX/
├── src/
│   └── dataenginex/
│       ├── api/         # FastAPI utilities (auth, health, pagination, rate limiting)
│       ├── core/        # Medallion architecture, validators, schemas
│       ├── data/        # Connectors, profiler, schema registry
│       ├── dashboard/   # Streamlit dashboard
│       ├── lakehouse/   # Catalog, partitioning, storage backends
│       ├── middleware/  # Structured logging, Prometheus metrics, tracing
│       ├── ml/          # Training, registry, serving, drift, LLM, RAG
│       ├── plugins/     # Plugin system (entry-point based discovery)
│       └── warehouse/   # SQL/Spark transforms, column-level lineage
├── examples/            # Runnable scripts (01–10)
├── tests/
│   ├── unit/            # Unit tests
│   ├── integration/     # End-to-end tests (requires docker-compose.test.yml)
│   └── fixtures/        # Sample data
├── Dockerfile           # Multi-stage, non-root, port 8000
└── docker-compose.test.yml  # S3 + GCS emulators for integration tests
```

## DEX Ecosystem Data Flow

```
Ingest → Process (Spark/Flink) → Lakehouse → Warehouse → Feature Store → Model Serving → AI Apps & Agents
                                                   ↑
                              Terraform → K8s → GitOps (infradex)
```
