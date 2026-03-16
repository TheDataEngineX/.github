# ML Guide

All ML functionality lives in `dataenginex.ml`. The core install includes the module — no extra required unless you use `SentenceTransformerEmbedder` (which needs `[ml]`).

## ModelRegistry

`ModelRegistry` provides a JSON-persisted model lifecycle manager with four stages: `development → staging → production → archived`.

```python
from dataenginex.ml import ModelRegistry

registry = ModelRegistry(storage_path="./model-registry.json")

# Register a model
registry.register(
    name="salary-predictor",
    version="1.0.0",
    artifact_path="./models/salary_predictor.pkl",
    metadata={"framework": "xgboost", "accuracy": 0.91},
)

# Promote through lifecycle
registry.promote("salary-predictor", "1.0.0", target_stage="staging")
registry.promote("salary-predictor", "1.0.0", target_stage="production")

# List models
models = registry.list_models()
```

Model serialization uses `SafeUnpickler` (restricts deserialization to sklearn/numpy namespaces) with HMAC signature verification on load. Set `DATAENGINEX_MODEL_HMAC_KEY` in your environment.

## RAG Pipeline

`RAGPipeline` orchestrates document ingestion and semantic retrieval. It wraps a `VectorStoreBackend` and an optional embedding function.

### Vector Store Backends

| Backend | Description |
|---------|-------------|
| `InMemoryBackend` | In-process vector store (dev/test) |
| `ChromaDBBackend` | Persistent ChromaDB store (production) |

```python
from dataenginex.ml import RAGPipeline, InMemoryBackend

backend = InMemoryBackend()
pipeline = RAGPipeline(vector_store=backend)

# Ingest documents
pipeline.ingest([
    {"id": "doc1", "text": "Data engineering best practices..."},
    {"id": "doc2", "text": "Medallion architecture overview..."},
])

# Retrieve relevant documents
results = pipeline.retrieve("How does medallion architecture work?", top_k=3)
```

### SentenceTransformerEmbedder (v0.6.1+)

A thin wrapper over `sentence-transformers` using `all-MiniLM-L6-v2` by default. Implements the `embed_fn` protocol for `RAGPipeline`.

```bash
pip install dataenginex[ml]
```

```python
from dataenginex.ml import RAGPipeline, InMemoryBackend, SentenceTransformerEmbedder

embedder = SentenceTransformerEmbedder(model_name="all-MiniLM-L6-v2")
pipeline = RAGPipeline(vector_store=InMemoryBackend(), embed_fn=embedder)
```

### Full RAG Loop with RAGPipeline.answer() (v0.6.1+)

`RAGPipeline.answer(question, llm, ...)` performs the complete retrieve → augment → generate loop in one call:

```python
from dataenginex.ml import RAGPipeline, InMemoryBackend, OllamaProvider

llm = OllamaProvider(model="llama3.2")
pipeline = RAGPipeline(vector_store=InMemoryBackend(), embed_fn=embedder)
pipeline.ingest(documents)

answer = pipeline.answer(
    question="What is the medallion architecture?",
    llm=llm,
    top_k=3,
)
print(answer)
```

See `examples/05_rag_demo.py` for a complete end-to-end demo with CLI flags (`--embed`, `--llm`, `--model`).

## LLM Providers

`LLMProvider` is an ABC with two concrete implementations:

### OllamaProvider

Connects to a local [Ollama](https://ollama.ai) instance via REST API.

```python
from dataenginex.ml import OllamaProvider, LLMConfig

llm = OllamaProvider(
    config=LLMConfig(
        model="llama3.2",
        base_url="http://localhost:11434",
        temperature=0.7,
        max_tokens=512,
    )
)

response = llm.generate("Summarize the medallion architecture in one paragraph.")
print(response.text)

# RAG-style augmented generation
response = llm.generate_with_context(
    question="What is data quality?",
    context="Data quality measures completeness, freshness, and uniqueness...",
)
```

`OllamaProvider` raises `ConnectionError` on HTTP failures (no silent empty responses).

### MockProvider

For testing without a running LLM:

```python
from dataenginex.ml import MockProvider

llm = MockProvider(responses=["Mock answer 1", "Mock answer 2"])
response = llm.generate("Any question")
```

### Key Dataclasses

| Class | Purpose |
|-------|---------|
| `LLMConfig` | Model name, base URL, temperature, max tokens |
| `LLMResponse` | Generated text, token counts, model metadata |
| `ChatMessage` | Role + content for multi-turn conversations |

## Drift Detector

PSI (Population Stability Index) based drift detection:

```python
from dataenginex.ml import DriftDetector

detector = DriftDetector(psi_threshold=0.2)

# Compare reference vs current distribution
report = detector.detect(
    reference=reference_dataframe["feature"],
    current=current_dataframe["feature"],
)

if report.is_drifted:
    print(f"Drift detected: PSI={report.psi_score:.4f}")
```

PSI interpretation:
- `< 0.1` — No drift
- `0.1–0.2` — Moderate drift, investigate
- `> 0.2` — Significant drift, retrain model

## PySpark ML Pipelines

For Spark-based ML, see `examples/08_spark_ml.py` in the repository. PySpark is an optional dependency — the core package does not require it.
