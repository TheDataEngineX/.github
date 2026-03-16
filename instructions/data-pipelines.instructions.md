---
applyTo: "src/**/data/**/*.py,src/**/pipeline/**/*.py,src/**/connectors/**/*.py,src/**/lineage/**/*.py,src/**/quality/**/*.py"
---

# Data Pipeline Standards

Extends `python.instructions.md`.

## Medallion architecture

- **Bronze** — raw ingestion only, schema validated at entry, no transformation
- **Silver** — cleaned, deduplicated, typed, joined
- **Gold** — aggregated, business-ready, quality-gated

Never skip layers. Never write gold-layer logic in bronze ingestion.

## Idempotency

Every pipeline must be safe to re-run:

- Watermarks or `updated_at` for incremental extraction — never full-reload by default
- Deduplication in silver, not bronze
- Writes must be upsert or partition-replace — never blind append to final tables

## Quality gates

- Validate schema at the bronze boundary (`SchemaRegistry`)
- Silver: completeness ≥ 0.95, uniqueness on key columns
- Gold: completeness ≥ 0.99, freshness ≤ configured SLA
- Fail loudly on quality violations — never silently pass bad data downstream

## Connectors

- Every connector extends `BaseConnector`
- Credentials from env vars / Pydantic settings — never hardcoded
- Specific exceptions: `ConnectionError`, `TimeoutError` — not bare `Exception`
- Log row counts, source, and destination at each stage

## Lineage

- Track column-level lineage via `LineageTracker` — every transform must be registered
- Never drop lineage events silently — log failures

## Performance

- Never load full datasets into memory — use chunked reads or streaming
- No unbounded result sets — always paginate or limit
- Log record counts and timing at each stage

## Checklist

- [ ] Pipeline is idempotent (safe to re-run)
- [ ] Schema validated at bronze entry point
- [ ] Quality scorecard at silver and gold
- [ ] Connector credentials from env vars
- [ ] Lineage events registered for all transforms
- [ ] Row counts logged at each stage
- [ ] No full-dataset in-memory load
