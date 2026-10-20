---
name: file-uploads
description: "Manages file uploads to S3 and Cloudflare R2 via presigned URLs, multipart uploads for large objects, and on-the-fly image optimization with sharp or ImageMagick. Use when building upload endpoints, generating presigned PUT or POST URLs, handling multipart initiation and completion, validating magic bytes for .jpg .png .pdf .mp4 .zip, enforcing size limits against 413 errors, sanitizing filenames against path traversal, configuring bucket CORS for browser direct upload, setting IAM policies for least-privilege access, running clamav scans, or debugging presigned URL expiration and multipart timeout failures."
---

# File Uploads & Storage

Securely accept, validate, store, and serve user-uploaded files using cloud object storage. Prefer presigned URLs over server proxying. Never trust client-provided metadata.

## When to use

- Building an upload endpoint or direct-to-storage flow
- Generating presigned URLs for S3 or Cloudflare R2
- Handling large files with multipart uploads
- Optimizing or transforming uploaded images
- Auditing upload security (validation, size limits, path traversal)

## Core principles

- Never trust file extensions or client-provided MIME types. Validate magic bytes on the server.
- Never proxy large files through your application server. Use presigned URLs for direct-to-storage uploads.
- Enforce size limits at every layer: client, gateway, and storage policy.
- Sanitize filenames. Never use user input directly in storage keys or filesystem paths.
- Treat every uploaded file as untrusted until validated and scanned.

## Upload strategies

### Direct upload with presigned URL (preferred)

1. Client requests an upload URL from your API.
2. Server validates the user's permission and intended file type.
3. Server generates a presigned PUT URL with constraints (content type, max size, expiry).
4. Client uploads directly to S3/R2 using the presigned URL.
5. Client notifies your API that upload is complete.
6. Server verifies the object exists and matches expected metadata.

### Server-proxied upload (small files only)

Use only for small files (< 5 MB) where you need to inspect content before storing. Stream to storage; do not buffer entire file in memory.

### Multipart upload (large files)

For files larger than 100 MB or unreliable networks:

1. Initiate multipart upload via S3/R2 API.
2. Split file into parts (5-100 MB each, last part can be smaller).
3. Upload parts in parallel with presigned URLs per part.
4. Complete multipart upload with the list of part ETags.
5. Abort incomplete uploads after a timeout to avoid storage costs.

## Security rules

### Validate magic bytes

Check the file's actual content, not its extension or declared type.

```python
import magic

def validate_file_type(file_bytes: bytes, allowed: set[str]) -> bool:
    mime = magic.from_buffer(file_bytes[:2048], mime=True)
    return mime in allowed
```

Common magic byte signatures:

| Type | Magic bytes (hex) |
| --- | --- |
| JPEG | `FF D8 FF` |
| PNG | `89 50 4E 47` |
| GIF | `47 49 46 38` |
| PDF | `25 50 44 46` |
| ZIP | `50 4B 03 04` |

### Enforce size limits

- Set `Content-Length` checks on presigned URLs.
- Configure bucket policies or lifecycle rules for max object size.
- Reject uploads exceeding limits before generating URLs.
- Use `Content-Length-Range` condition in presigned POST policies.

### Sanitize filenames

```python
import re, uuid

def safe_key(original_name: str, user_id: str) -> str:
    ext = original_name.rsplit(".", 1)[-1].lower() if "." in original_name else ""
    allowed_exts = {"jpg", "jpeg", "png", "gif", "pdf", "zip"}
    if ext not in allowed_exts:
        raise ValueError("Disallowed extension")
    return f"uploads/{user_id}/{uuid.uuid4()}.{ext}"
```

- Strip path separators and null bytes.
- Generate a new UUID-based key; do not preserve original filename in storage path.
- Store original filename as metadata if needed.

### Control presigned URL distribution

- Set short expiry (5-15 minutes for uploads, 1-60 minutes for downloads).
- Bind to specific content type and size constraints.
- Do not log or cache presigned URLs.
- Revoke by rotating credentials if a URL leaks.
- Use single-use tokens where possible.

## S3 / R2 configuration

### Bucket setup

- Enable versioning for recovery.
- Block public access by default; use presigned URLs or CDN for serving.
- Enable server-side encryption (SSE-S3 or SSE-KMS).
- Set CORS rules for direct browser uploads.

### CORS example

```json
[
  {
    "AllowedOrigins": ["https://app.example.com"],
    "AllowedMethods": ["PUT", "POST", "GET"],
    "AllowedHeaders": ["Content-Type", "Content-Length"],
    "MaxAgeSeconds": 3600
  }
]
```

### Presigned URL generation (Python / boto3)

```python
import boto3

s3 = boto3.client("s3")

url = s3.generate_presigned_url(
    "put_object",
    Params={
        "Bucket": "my-bucket",
        "Key": "uploads/user123/abc.jpg",
        "ContentType": "image/jpeg",
    },
    ExpiresIn=300,
)
```

### Cloudflare R2

R2 is S3-compatible. Use the same boto3 code with a custom endpoint:

```python
s3 = boto3.client(
    "s3",
    endpoint_url="https://<account>.r2.cloudflarestorage.com",
    aws_access_key_id=R2_ACCESS_KEY,
    aws_secret_access_key=R2_SECRET_KEY,
)
```

R2 has no egress fees, making it cost-effective for serving files.

## Image optimization

- Resize on upload or on first request (lazy transform).
- Generate thumbnails at fixed sizes (e.g., 150x150, 400x400, 1200x1200).
- Strip EXIF metadata to remove GPS and camera data.
- Convert to WebP or AVIF for web delivery.
- Use a CDN with image transformation (Cloudflare Images, imgix, or Sharp).

```javascript
// Sharp example
const sharp = require("sharp");
const output = await sharp(inputBuffer)
  .resize(1200, 1200, { fit: "inside", withoutEnlargement: true })
  .webp({ quality: 80 })
  .toBuffer();
```

## Serving files

- Serve through a CDN, not directly from origin.
- Use presigned GET URLs for private files with short expiry.
- Set `Content-Disposition: attachment` for downloads to prevent inline execution.
- Set correct `Content-Type` from validated metadata, not user input.
- Add `X-Content-Type-Options: nosniff` header.

## Malware scanning

- Scan uploads with ClamAV or a cloud scanning service before making them available.
- Quarantine suspicious files in a separate bucket.
- Do not serve files from the upload bucket until scanned.

## Cleanup and lifecycle

- Set lifecycle rules to delete incomplete multipart uploads after 7 days.
- Delete orphaned files when database records are removed.
- Use soft-delete with a retention period before permanent deletion.
- Monitor storage usage and set billing alerts.

## Pitfalls

- Trusting `Content-Type` header from the client.
- Using original filename as storage key (path traversal, collisions).
- Buffering large files in memory (OOM crashes).
- Missing CORS configuration causing browser upload failures.
- Not aborting incomplete multipart uploads (storage cost leak).
- Serving user uploads from the same origin as the app (XSS risk).
- Not stripping EXIF data (privacy leak).
- Allowing executable file types (.html, .svg with scripts, .exe).

## Checklist

- [ ] Magic bytes validated server-side
- [ ] Size limits enforced at all layers
- [ ] Filenames sanitized; UUID-based storage keys
- [ ] Presigned URLs have short expiry and constraints
- [ ] CORS configured for direct browser uploads
- [ ] Server-side encryption enabled
- [ ] Public access blocked by default
- [ ] Image optimization pipeline in place
- [ ] Malware scanning before serving
- [ ] Lifecycle rules for incomplete uploads
- [ ] CDN configured for serving
- [ ] Content-Disposition and nosniff headers set

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`cloudflare-deploy`](../cloudflare-deploy/SKILL.md) — Deploy applications and infrastructure to Cloudflare using Workers, Pages, and related services. Use this skil…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`application-security`](../application-security/SKILL.md) — Application security guidance for threat modeling, secure design, code review, dependency and supply-chain ris…
