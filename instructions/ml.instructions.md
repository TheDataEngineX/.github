---
applyTo: "src/**/ml/**/*.py,src/**/models/**/*.py,src/**/registry/**/*.py,src/**/drift/**/*.py"
---

# ML Standards

Extends `python.instructions.md`.

## Model lifecycle (via `ModelRegistry`)

```
development → staging → production → archived
```

- Never serve a model that hasn't passed staging validation
- Promotion to production requires explicit approval — not automatic
- Archived models are never deleted — status change only
- Store: name, version, metrics, artifact path, created_at, promoted_by

## Logging

Use `loguru` for all ML code — not structlog:

```python
from loguru import logger
logger.info("training complete epoch={} loss={:.4f}", epoch, loss)
```

## Training

- Log hyperparameters before training starts
- Log metrics at every epoch: loss, accuracy, domain metrics
- Checkpoint during long runs — never lose progress on failure
- Validate training data schema before fitting
- Always hold out a validation set — never train on 100% of data

## Drift detection

- PSI-based (built into `ModelRegistry`)
- PSI > 0.10 → warning, PSI > 0.25 → critical
- Run checks on every prediction batch
- Log PSI value, feature name, and timestamp

## Inference

- Load model once at startup — never reload per request
- Validate input schema (Pydantic) before inference
- Return prediction + confidence score — never bare label only
- Track latency: `ml_prediction_duration_seconds` (Prometheus histogram)

## Checklist

- [ ] Model registered in `ModelRegistry` with full metadata
- [ ] Lifecycle state explicit
- [ ] Drift detection wired for production models
- [ ] Input schema validated before inference
- [ ] Prediction latency tracked as Prometheus metric
- [ ] Training metrics logged per epoch
- [ ] No full-dataset load during inference
