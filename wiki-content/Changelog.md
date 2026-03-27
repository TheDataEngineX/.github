# Changelog

See [CHANGELOG.md](https://github.com/TheDataEngineX/DEX/blob/main/CHANGELOG.md) for the full history.

## Latest: v0.6.1 — 2026-03-15

### Added

- **`SentenceTransformerEmbedder`** — thin wrapper over `sentence-transformers` (`all-MiniLM-L6-v2` default). Install via `uv add 'dataenginex[ml]'`. Implements the `embed_fn` protocol for `RAGPipeline`.
- **`RAGPipeline.answer(question, llm, ...)`** — full retrieve → augment → generate loop in one call. Combines `build_context` with any `LLMProvider.generate_with_context`.
- **GitHub Actions upgraded to Node.js 24** — `ci.yml`, `pypi-publish.yml`, `release-dataenginex.yml`, `security.yml` now use `actions/checkout@v6`, `actions/setup-python@v6`, `astral-sh/setup-uv@v7`.
- **`examples/05_rag_demo.py`** — end-to-end RAG demo with `--embed`, `--llm`, `--model` CLI flags; Ollama fallback to MockProvider; uses `RAGPipeline.answer()`.

---

## v0.6.0 — 2026-03-03

### Breaking Changes

- **Routers removed** — `api/routers/v1.py` and `api/routers/ml.py` consolidated into the dataenginex monorepo. `dataenginex` provides reusable API utilities (auth, health, errors, pagination, rate limiting).
- **FastAPI is now optional** — Core install (`pip install dataenginex`) includes only lightweight deps: `pydantic`, `pyyaml`, `structlog`, `httpx`, `python-dotenv`, `prometheus-client`. API/middleware consumers must install `pip install dataenginex[api]`.
- **Root `__init__.py` slimmed** — `from dataenginex import ...` no longer re-exports `HealthChecker`, `HealthStatus`, `configure_logging`, `configure_tracing`, `get_logger`. Use `from dataenginex.api import ...` or `from dataenginex.middleware import ...` directly.
- **Domain consolidation** — All domain schemas and validators consolidated into the dataenginex monorepo. Domain models live alongside the core library.

### Added

- **RAG Vector DB adapter** — `VectorStoreBackend` ABC with `InMemoryBackend` and `ChromaDBBackend` implementations; `RAGPipeline` orchestrator; `Document` and `SearchResult` dataclasses.
- **LLM integration** — `LLMProvider` ABC with `OllamaProvider` and `MockProvider`; `generate_with_context()` for RAG-style augmented generation; `ChatMessage`, `LLMConfig`, `LLMResponse` dataclasses.
- **Injectable `QualityGate`** — `QualityGate.__init__` now accepts `scorer`, `required_fields`, and `uniqueness_key` keyword arguments.
- **Real `LocalParquetStorage`** — Reads/writes actual Parquet files via `pyarrow`.
- **`BigQueryStorage` stubbed** — All methods raise `NotImplementedError` until implemented.

### Fixed

- **Pickle safety** — `ml/training.py` now uses `SafeUnpickler` restricting deserialization to sklearn/numpy namespaces only; HMAC signature verification on model load.
- **LLM error handling** — `OllamaProvider.generate()`/`chat()` raise `ConnectionError` on HTTP failures instead of returning empty `LLMResponse`.
- **Pagination cursor** — `decode_cursor()` raises `ValueError` on invalid input instead of silently returning 0.
- **Storage backends** — `S3Storage.exists()` catches `NoSuchKey` specifically; `GCSStorage.exists()` returns `blob.exists()` with specific exception handling.

---

## v0.5.0 — 2026-03-01

### Added

- **Storage abstraction** — `list_objects(prefix)` and `exists(path)` on `StorageBackend` ABC; concrete implementations across all backends; `get_storage(uri)` factory function.

---

For earlier versions, see the [full CHANGELOG](https://github.com/TheDataEngineX/DEX/blob/main/CHANGELOG.md).
