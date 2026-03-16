---
applyTo: "src/**/api/**/*.py"
---

# FastAPI Standards

Extends `python.instructions.md`.

## Endpoints

- Every endpoint must have `response_model=` — no untyped responses
- Correct HTTP verbs: GET (read), POST (create), PATCH (partial update), PUT (replace), DELETE
- Versioned routes: `/api/v1/`, `/api/v2/` — never unversioned business endpoints
- Docstring on every endpoint (shows in OpenAPI)

## Request / Response models

- Pydantic v2 models for all request bodies and responses
- Never pass raw dicts through business logic — always typed models
- Never expose internal IDs or implementation details in response schemas

## Auth

- Protected endpoints check auth via lifespan middleware — not inline per endpoint
- Auth: pure-Python HS256 JWT (no `pyjwt` dependency)
- Return `401` for missing/invalid token, `403` for insufficient permissions
- Never log the token or any credential

## Middleware order (lifespan)

Request logging → Prometheus metrics → auth → rate limiting. Do not reorder.

## Error responses

All errors return a consistent JSON body via `HTTPException`:

```json
{"detail": "human-readable message", "code": "MACHINE_READABLE_CODE"}
```

Never return raw strings as error bodies.

## Observability

- Prometheus: `http_requests_total`, `http_request_duration_seconds` on every endpoint
- Use `http_` prefix for all HTTP metrics
- OpenTelemetry span per request — propagate trace context from headers

## Checklist

- [ ] `response_model=` on every endpoint
- [ ] Pydantic model for every request body
- [ ] Versioned route (`/api/v1/`)
- [ ] Auth via middleware (not inline)
- [ ] Prometheus metrics updated
- [ ] Errors use `HTTPException` with JSON detail
- [ ] Docstring on endpoint
