# Django Development Skill

Expert guidance for building, testing, and deploying Django 5.x applications. Use this skill for new projects or when you need to improve an existing codebase with async, API, background tasks, real‑time features, or robust security.

## When to use
- You are writing or refactoring a Django 5.x application.
- You need to design a scalable project structure.
- You want to add async views, DRF APIs, Celery tasks, or Channels consumers.
- You must improve performance, testing, security, or deployment.

## Core Django Practices
- Use **class‑based views** for reusable logic; fall back to function‑based views only for simple endpoints.
- Keep business logic out of views. Place it in a **service layer** (plain Python modules) or **model managers**.
- Define **custom model managers** for common query patterns.
- Apply **`select_related`** for foreign‑key joins and **`prefetch_related`** for many‑to‑many or reverse FK to avoid N+1 queries.
- Add **database indexes** on fields used in filters, ordering, or lookups.
- Use **type hints** and docstrings on all public functions.

```python
# models.py
class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20)

    objects = models.Manager()
    active = ActiveOrderManager()  # custom manager

# managers.py
class ActiveOrderManager(models.Manager):
    def get_queryset(self) -> QuerySet["Order"]:
        return super().get_queryset().filter(status="active")
```

## Project Architecture
- Split the project into **core** (settings, URLs, wsgi/asgi) and **feature apps** (e.g., `accounts`, `billing`).
- Store **environment‑specific settings** in separate files (`settings/base.py`, `settings/dev.py`, `settings/prod.py`). Load them with `django-environ`.
- Keep **third‑party configuration** (e.g., Celery, Redis) in dedicated modules (`celery.py`, `cache.py`).
- Use the **repository pattern** only when you need a clear abstraction over complex queries; otherwise rely on model managers.

## Async & Real‑time
- Write async views only when the view performs I/O (e.g., external HTTP calls) and the whole stack supports ASGI.
- Deploy with an ASGI server (`uvicorn`, `daphne`, or `hypercorn`).
- For WebSockets, use **Django Channels**.

```python
# views.py (async example)
from django.http import JsonResponse
import httpx

async def external_status(request):
    async with httpx.AsyncClient() as client:
        resp = await client.get('https://api.example.com/status')
    return JsonResponse({'status': resp.json()})
```

```python
# consumers.py (Channels example)
from channels.generic.websocket import AsyncJsonWebsocketConsumer

class NotificationConsumer(AsyncJsonWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add('notifications', self.channel_name)
        await self.accept()

    async def disconnect(self, code):
        await self.channel_layer.group_discard('notifications', self.channel_name)

    async def notify(self, event):
        await self.send_json(event['payload'])
```

## API Development (DRF)
- Use **ViewSets** with routers for standard CRUD.
- Apply **`serializer.save()`** inside `perform_create`/`perform_update` to keep view logic thin.
- Secure APIs with **JWT** (`djangorestframework-simplejwt`) or **OAuth2** (`django-oauth-toolkit`).
- Enforce object‑level permissions with **django‑guardian** when needed.

```python
# serializers.py
from rest_framework import serializers
from .models import Order

class OrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = '__all__'
        read_only_fields = ('id', 'created_at')
```

```python
# viewsets.py
from rest_framework import viewsets, permissions
from .models import Order
from .serializers import OrderSerializer

class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.select_related('user').all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]
```

## Background Tasks (Celery)
- Run Celery workers with **Redis** or **RabbitMQ** as broker.
- Keep tasks **idempotent** and **short**; chain or chord for longer workflows.
- Use **`@shared_task`** for reusable tasks across apps.
- Wrap database operations in **`transaction.atomic`** to guarantee consistency.

```python
# tasks.py
from celery import shared_task
from django.db import transaction
from .models import Report

@shared_task(bind=True, max_retries=3)
def generate_report(self, report_id):
    try:
        with transaction.atomic():
            report = Report.objects.get(pk=report_id)
            report.status = 'processing'
            report.save()
            # heavy computation here
            report.result = compute()
            report.status = 'ready'
            report.save()
    except Exception as exc:
        self.retry(exc=exc, countdown=60)
```

## Testing
- Use **pytest‑django** for fast, expressive tests.
- Create factories with **factory_boy** for realistic test data.
- Separate **unit**, **integration**, and **end‑to‑end** tests.
- Run **coverage** and enforce a minimum threshold (e.g., 85%).
- Profile queries with **django‑silk** or **assertNumQueries**.

```python
# test_views.py
import pytest
from django.urls import reverse
from rest_framework.test import APIClient
from .factories import OrderFactory

@pytest.mark.django_db
def test_order_list():
    OrderFactory.create_batch(5)
    client = APIClient()
    url = reverse('order-list')
    response = client.get(url)
    assert response.status_code == 200
    assert len(response.json()) == 5
```

## Security
- Enable **`SecurityMiddleware`**, **`XContentTypeOptionsMiddleware`**, and **`XFrameOptionsMiddleware`**.
- Set **`SECURE_HSTS_SECONDS`**, **`SECURE_SSL_REDIRECT`**, and **`SESSION_COOKIE_SECURE`** in production.
- Use **custom user model** from project start.
- Store secrets in environment variables; never commit them.
- Validate all input with serializers or forms; never trust client data.
- Apply **CSRF protection** on state‑changing endpoints; exempt only when using token‑based APIs.
- Limit **CORS** origins to trusted domains.

## Database & ORM Optimization
- Prefer **`select_related`** for one‑to‑one/foreign‑key joins; use **`prefetch_related`** for many‑to‑many or reverse FK.
- Annotate aggregates with **`annotate()`** to avoid extra queries.
- Use **`bulk_create`**, **`bulk_update`**, and **`update()`** for batch operations.
- Keep migrations small; combine related schema changes into a single migration file.
- For PostgreSQL, leverage **`JSONField`**, **`ArrayField`**, and **full‑text search** (`SearchVector`).
- Enable **connection pooling** with **`django-db-pool`** or external tools like **PgBouncer**.

## Deployment & DevOps
- Containerize with **Docker** using multi‑stage builds: build stage installs dependencies, runtime stage copies only compiled assets.
- Serve static files with **WhiteNoise** or a CDN; store media in **S3** via `django-storages`.
- Use **Gunicorn** (WSGI) for sync apps and **Uvicorn** (ASGI) for async apps.
- Configure **logging** with JSON format for log aggregation services (e.g., ELK, DataDog).
- Set up **CI/CD** pipelines that run linting, tests, and security scans on each push.
- Store environment variables in a secret manager (e.g., AWS Secrets Manager, Vault).

## Frontend Integration
- Use **Django templates** for simple pages; embed **HTMX** for progressive enhancement without heavy JavaScript.
- For SPA frontends, expose APIs via DRF and host the compiled bundle with **django-webpack-loader** or serve from a separate static host.
- Implement **server‑side rendering** for SEO‑critical pages when using React/Vue with frameworks like **Next.js**.

## Common Pitfalls
- Mixing sync and async code without proper adapters leads to thread‑blocking; keep async views isolated.
- Over‑using third‑party packages; prefer built‑in Django features first.
- Storing large files in the database; use external storage instead.
- Forgetting to run **`collectstatic`** in production; static files become unavailable.
- Ignoring database transaction boundaries; partial writes cause data inconsistency.
- Not setting **`ALLOWED_HOSTS`**; this opens host‑header attacks.

## Checklist
- [ ] Define a custom user model before the first migration.
- [ ] Separate settings per environment and load with `django-environ`.
- [ ] Add indexes on filterable fields.
- [ ] Use `select_related`/`prefetch_related` to eliminate N+1 queries.
- [ ] Write at least one test for each view, model, and task.
- [ ] Run `pytest --cov=yourapp` and enforce a coverage threshold.
- [ ] Configure security middleware and HTTPS settings for production.
- [ ] Containerize with Docker; verify both WSGI and ASGI servers work.
- [ ] Set up Celery beat for periodic tasks and monitor with Flower.
- [ ] Document API endpoints with OpenAPI/Swagger via DRF Spectacular.
- [ ] Review logging configuration; ensure no secrets are logged.
- [ ] Perform a load test on critical endpoints; profile with `django-silk`.

## Related skills

Load these when the task spans more than this skill.

- [`python`](../../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`backend-development`](../SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`database-optimization`](../../database-design/references/database-optimization.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`unit-testing-patterns`](../../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
