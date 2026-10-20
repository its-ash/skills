# API Documentation Generator

Create clear, developer‑friendly documentation for any API and produce a ready‑to‑copy handoff file for frontend teams. The skill works for REST, GraphQL, and WebSocket APIs.

## When to Use
- A new API is ready for release.
- Existing documentation is missing or out of date.
- Frontend developers need a handoff document after backend work is finished.
- You want an OpenAPI/Swagger spec, Postman collection, or interactive examples.
- You need consistent error, auth, and rate‑limit information.

## Workflow
### 1. Analyze the API
- Scan the codebase for routes, methods, and handlers.
- Identify request parameters, body schemas, and response schemas.
- Detect authentication/authorization requirements.
- List possible error codes and messages.
- Note pagination, filtering, sorting, and rate‑limit logic.

### 2. Generate Full Documentation
For each endpoint create the following sections:
1. **Endpoint Details** – HTTP method, URL, short purpose, auth, rate limits.
2. **Request Specification** – path, query, headers, body schema (type, constraints, required/optional).
3. **Response Specification** – success status, body schema, response headers, error status codes.
4. **Code Examples** – cURL, JavaScript (fetch/axios), Python (requests). Add more languages if needed.
5. **Usage Guidelines** – quick‑start steps, common use cases, pagination pattern, filtering syntax.
6. **Error Handling** – list all error codes, message format, troubleshooting tips.
7. **Interactive Assets** – OpenAPI/Swagger YAML, Postman collection JSON, optional sandbox URL.

### 3. Add Handoff Section for Frontend
Produce a single markdown block that frontend developers can copy directly. Use the template below and fill with concrete data.

```markdown
# API Handoff: <Feature Name>

## Business Context
[2‑4 sentences: problem solved, primary users, key domain terms]

## Endpoints

### <METHOD> /path/to/endpoint
- **Purpose**: [one‑line description]
- **Auth**: [role, permission, or "public"]
- **Request**:
  ```json
  {
    "field": "type — description, constraints"
  }
  ```
- **Response (success)**:
  ```json
  {
    "field": "type — description"
  }
  ```
- **Response (error)**: HTTP codes and payload shapes (e.g., 422 validation, 404 not found)
- **Notes**: edge cases, rate limits, pagination, sorting, etc.

[Repeat for each endpoint]

## Data Models / DTOs
[List models the frontend will receive or send. Include types, nullability, enums, and business meaning.]

```typescript
interface ExampleDto {
  id: number;
  status: "pending" | "approved" | "rejected";
  createdAt: string; // ISO‑8601
}
```

## Enums & Constants
| Value | Meaning | Display |
|-------|---------|---------|
| `pending` | Awaiting review | Pending |
| `approved` | Approved by admin | Approved |

## Validation Rules
- Required fields, min/max lengths, regex patterns, conditional rules.
- Mirror these rules in UI validation for instant feedback.

## Business Logic & Edge Cases
- Bullet each non‑obvious rule (e.g., "User can submit only once per day", "Soft‑deleted items are excluded by default").

## Integration Notes
- **Recommended flow**: e.g., "Fetch list → select item → submit form → poll status".
- **Optimistic UI**: safe or not, and why.
- **Caching**: cache‑control headers, invalidation triggers.
- **Real‑time**: websocket events or polling intervals.

## Test Scenarios
1. **Happy path** – expected request and response.
2. **Validation error** – trigger condition and error payload.
3. **Not found** – when 404 is returned.
4. **Permission denied** – when 403 is returned.

## Open Questions / TODOs
[Unresolved items, pending decisions, or places where frontend input is required. Omit if none.]
```

### 4. Review & Publish
- Verify that request/response examples match the actual implementation.
- Run API tests that compare live responses to the documented schemas.
- Commit the full documentation (README, wiki, or docs site) and the handoff file to the project repository.

## Documentation Structure (Full Document)
1. **Introduction** – purpose, base URL, version, support contact.
2. **Authentication** – token type, acquisition flow, expiration, refresh.
3. **Quick Start** – minimal example to call the API.
4. **Endpoints** – grouped by resource, each following the template above.
5. **Data Models** – schema definitions, field descriptions, validation.
6. **Error Handling** – error code table, response format, troubleshooting.
7. **Rate Limiting** – limits, headers, retry strategy.
8. **Changelog** – version history, breaking changes.
9. **SDKs & Tools** – links to client libraries, Postman collection, OpenAPI spec.

## Best Practices
- **Consistency** – use the same layout for every endpoint.
- **Complete examples** – test all code snippets; they must run.
- **Error coverage** – document every error the client can receive.
- **Realistic data** – avoid placeholder values like "foo".
- **Versioning** – include API version in URLs and docs.
- **Timestamp** – show last updated date.
- **Link related endpoints** – help users discover related calls.
- **Rate limit info** – always state limits and how to handle them.
- **Provide Postman collection** – enable quick testing.

## Common Pitfalls & Solutions
| Problem | Symptoms | Solution |
|---------|----------|----------|
| Docs out of sync | Examples fail, wrong parameters | Generate docs from code comments or OpenAPI; run doc‑validation tests on every change |
| Missing error info | Users see unknown failures | List every error code, include sample payloads, add troubleshooting steps |
| Broken examples | Users cannot copy‑paste to test | Run each snippet against a staging environment before publishing |
| Unclear parameter rules | Frequent validation errors | Mark required vs optional, specify types, formats, min/max, and give example values |

## Tools & Formats
### OpenAPI / Swagger
```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0
paths:
  /users:
    post:
      summary: Create a new user
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
```
### Postman Collection
```json
{
  "info": {"name": "My API", "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"},
  "item": [{"name": "Create User", "request": {"method": "POST", "url": "{{baseUrl}}/api/v1/users"}}]
}
```

## Checklist
- [ ] Identify all endpoints, methods, and URLs.
- [ ] Document request parameters, body schema, and headers.
- [ ] Document success and error response schemas.
- [ ] Include authentication requirements for each endpoint.
- [ ] Provide cURL, JavaScript, and Python examples.
- [ ] Add pagination, sorting, and filtering details where applicable.
- [ ] List all error codes with sample payloads.
- [ ] Generate OpenAPI spec and Postman collection.
- [ ] Create the frontend handoff markdown block.
- [ ] Run automated tests to verify examples match live responses.
- [ ] Review for consistency, completeness, and up‑to‑date timestamps.
- [ ] Publish docs and handoff file to the repository.

---
*Keep documentation as close to the code as possible. Automate generation where feasible to avoid drift.*
