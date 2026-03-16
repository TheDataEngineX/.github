---
applyTo: "tests/**/*.py"
---

# Testing Standards

Extends `python.instructions.md`.

## Structure

- `tests/unit/` — isolated, no I/O, fast (< 1s each)
- `tests/integration/` — live server or real DB
- `tests/conftest.py` — shared fixtures only; no test logic
- One test file per source module: `src/foo/bar.py` → `tests/unit/test_bar.py`

## Naming

Describe the scenario, not the implementation:

```python
# Good
def test_pipeline_fails_when_source_schema_invalid():

# Bad
def test_run_method():
```

## Pattern: Arrange-Act-Assert

```python
def test_something():
    # Arrange
    pipeline = Pipeline(config=valid_config)

    # Act
    result = pipeline.run()

    # Assert
    assert result.status == "success"
    assert result.rows_processed == 100
```

## Async tests

`asyncio_mode = "auto"` is configured — never add `@pytest.mark.asyncio`.

## Mocking

- Mock external services (HTTP, DB, S3) — never mock code under test
- Use `httpx.MockTransport` for HTTP clients
- Integration tests hit real infrastructure — no mocks

## Coverage

- 80%+ on new code
- Error-handling paths must be covered
- Do not write empty tests to hit the number — test real behaviour

## Independence

- Any test must pass in isolation
- No shared mutable state between tests
- Fresh fixtures per test

## Edge cases to always cover

- Empty input / None values
- Boundary values (0, -1, max)
- Invalid types / missing required fields
- The happy path

## Checklist

- [ ] Test name describes the scenario
- [ ] Arrange-Act-Assert with blank lines
- [ ] No `@pytest.mark.asyncio`
- [ ] External services mocked, not internal code
- [ ] No inter-test dependencies
- [ ] Edge cases covered
- [ ] New code ≥ 80% coverage
