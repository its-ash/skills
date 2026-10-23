# Firebase Backend Development

Firebase provides a suite of cloud services for authentication, database, storage, and hosting. Because Firebase shifts much of the backend logic to the client, strict security rules and query-driven data modeling are critical to prevent data breaches and runaway costs.

## When to use
Use this skill when implementing any of the following:
- **Firebase Authentication**: Managing user identity and OAuth flows.
- **Cloud Firestore**: Designing NoSQL document structures and complex queries.
- **Realtime Database**: Implementing low-latency, synchronized state.
- **Cloud Functions**: Writing serverless triggers and HTTPS endpoints.
- **Cloud Storage**: Managing user-uploaded files and assets.
- **Firebase Hosting**: Deploying static and dynamic web content.
- **Security Rules**: Writing access control logic for Firestore and Storage.

## Data Modeling and Queries

Firebase is optimized for read-heavy, denormalized data. Unlike SQL, you must design your data structure based on your UI's query patterns rather than entity relationships.

### Firestore Design Rules
- **Denormalize Data**: Duplicate data across documents to avoid multiple reads or client-side joins.
- **Avoid Deep Nesting**: Use sub-collections instead of deeply nested maps to keep document sizes under the 1MB limit.
- **Query-First Design**: Define the exact filters and sorts needed for a view before creating the collection structure.
- **Use Composite Indexes**: Create composite indexes for queries involving multiple fields with inequality filters.

## Security Rules

Security rules are the only line of defense for client-side SDKs. Never deploy to production with `allow read, write: if true;`.

### Firestore Rules Patterns
- **Owner-Only Access**: Ensure users can only modify their own data.
  ```javascript
  match /users/{userId} {
    allow read, write: if request.auth != null && request.auth.uid == userId;
  }
  ```
- **Role-Based Access (RBAC)**: Use custom claims or a `roles` collection to verify permissions.
- **Validation**: Use `request.resource.data` to validate the schema of incoming writes.

### Cloud Storage Rules
- **File Type Validation**: Restrict uploads to specific MIME types (e.g., `image/jpeg`).
- **Size Limits**: Enforce maximum file sizes to prevent storage exhaustion.

## Cloud Functions

Use Cloud Functions for operations that require administrative privileges or heavy computation.

### Implementation Guidelines
- **Use Firebase Admin SDK**: Always use `firebase-admin` in functions to bypass security rules for trusted server-side operations.
- **Idempotency**: Ensure functions are idempotent, as they may execute more than once for a single event.
- **Cold Start Optimization**: Keep function dependencies minimal to reduce latency.
- **Avoid Infinite Loops**: When writing a function that triggers on a document update, ensure the function does not update the same document without a termination condition.

## Performance and Cost Optimization

### Avoiding Runaway Costs
- **Limit Listeners**: Avoid attaching real-time listeners (`onSnapshot`) to large collections. Use pagination or specific queries.
- **Pagination**: Implement `startAfter` or `limit` to avoid loading thousands of documents into memory.
- **Aggregation**: Use aggregation queries (`count()`, `sum()`, `avg()`) instead of fetching all documents to calculate a total.

### SDK Usage
- **Modular Imports**: Use the v9+ modular SDK to enable tree-shaking and reduce bundle size.
  ```javascript
  import { getFirestore, collection, getDocs } from 'firebase/firestore';
  ```

## Pitfalls and Anti-Patterns

- **❌ SQL Thinking**: Attempting to normalize data and perform joins in the client. This leads to excessive read costs and slow performance.
- **❌ Client-Side Admin Logic**: Performing sensitive operations (like updating a user's subscription status) directly from the client SDK.
- **❌ Missing Security Rules**: Relying on the client-side UI to hide buttons as a form of security.
- **❌ Over-using Realtime Database**: Using the Realtime Database for complex querying; use Firestore for structured data and RTDB for simple, high-frequency state sync.

## Checklist
- [ ] Security rules are defined for every collection and storage path.
- [ ] Data model is optimized for the specific UI query patterns.
- [ ] Modular SDK imports are used to minimize bundle size.
- [ ] Cloud Functions are idempotent and use the Admin SDK.
- [ ] Pagination is implemented for all large list views.
- [ ] Firebase Emulators are used for local development and testing.

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`cloud-architecture`](../../devops-iac/references/cloud-architecture.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`flutter`](../../flutter/SKILL.md) — Provides expert guidance for building high‑performance, multi‑platform Flutter apps with Dart 3. Use it for ar…
