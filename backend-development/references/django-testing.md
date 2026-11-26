@REF:django-testing
§USE{new_django_app∨drf_api∨model_view_serializer_test∨test_infra_setup∨pre_PR∨post_model_migration_Δ∨pre_deploy}

§TDD{RED(failing_test:create_user/check_password/¬is_staff)→GREEN(min_model/factory)→REFACTOR(keep_green)}

§CFG{
  pytest_ini:```ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings.test
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = --reuse-db --nomigrations --cov=apps --cov-report=html --cov-report=term-missing --strict-markers
markers =
    slow: slow tests
    integration: integration tests
```
  test_settings:```python
# config/settings/test.py
from .base import *
DEBUG = True
DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3', 'NAME': ':memory:'}}
class DisableMigrations:
    def __contains__(self, item): return True
    def __getitem__(self, item): return None
MIGRATION_MODULES = DisableMigrations()
PASSWORD_HASHERS = ['django.contrib.auth.hashers.MD5PasswordHasher']
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True
```
  conftest:```python
# tests/conftest.py
import pytest
from django.contrib.auth import get_user_model
User = get_user_model()
@pytest.fixture(autouse=True)
def timezone_settings(settings): settings.TIME_ZONE = 'UTC'
@pytest.fixture
def user(db): return User.objects.create_user(email='test@example.com', password='testpass123', username='testuser')
@pytest.fixture
def admin_user(db): return User.objects.create_superuser(email='admin@example.com', password='adminpass123', username='admin')
@pytest.fixture
def authenticated_client(client, user): client.force_login(user); return client
@pytest.fixture
def api_client():
    from rest_framework.test import APIClient
    return APIClient()
@pytest.fixture
def authenticated_api_client(api_client, user): api_client.force_authenticate(user=user); return api_client
```
}

§PAT{
  factory_boy:```python
import factory
from factory import fuzzy
class UserFactory(factory.django.DjangoModelFactory):
    class Meta: model = User
    email = factory.Sequence(lambda n: f"user{n}@example.com")
    username = factory.Sequence(lambda n: f"user{n}")
    password = factory.PostGenerationMethodCall('set_password', 'testpass123')
    first_name = factory.Faker('first_name')
    is_active = True
class ProductFactory(factory.django.DjangoModelFactory):
    class Meta: model = Product
    name = factory.Faker('sentence', nb_words=3)
    slug = factory.LazyAttribute(lambda o: o.name.lower().replace(' ', '-'))
    price = fuzzy.FuzzyDecimal(10.00, 1000.00, 2)
    stock = fuzzy.FuzzyInteger(0, 100)
    category = factory.SubFactory(CategoryFactory)
    created_by = factory.SubFactory(UserFactory)
    @factory.post_generation
    def tags(self, create, extracted, **kwargs):
        if create and extracted:
            for tag in extracted: self.tags.add(tag)
```
  factory_usage:`ProductFactory(price=100.00)`∧`ProductFactory(tags=[TagFactory()])`∧`ProductFactory.create_batch(10)`;
  models(db):check `user.check_password()`, `is_staff`/`is_superuser`, `str(obj)`, auto-slug, `pytest.raises(ValidationError)` on `obj.full_clean()`, custom managers (`Product.objects.active().count()`), state mutation + `obj.refresh_from_db()` + `pytest.raises(ValueError)` on invalid invariant;
  django_views(client,authenticated_client,db):`client.get(reverse('ns:name', kwargs={...}))`→`status_code∈{200,302}`, `response.context[...]`, unauth redirect `response.url.startswith('/accounts/login/')`, `authenticated_client.post(url, data)`→302∧`Model.objects.filter(...).exists()`;
  drf_serializers:`Serializer(obj).data` (`Decimal`→`str`), `s=Serializer(data=d)`→`s.is_valid()`→`s.save()`, invalid→`not s.is_valid() ∧ 'field' in s.errors` (`rest_framework.exceptions.ValidationError`);
  drf_viewsets(api_client,authenticated_api_client,db):
    - list/filter/search: `api_client.get(reverse('api:product-list'), {'price_min':100}|{'search':'Apple'})`→`HTTP_200_OK`, `response.data['count']`
    - retrieve: `api_client.get(reverse('api:product-detail', kwargs={'pk':id}))`→`HTTP_200_OK`
    - unauth create: `api_client.post(...)`→`HTTP_401_UNAUTHORIZED`
    - auth create/patch/delete: `HTTP_201_CREATED` / `patch`→`HTTP_200_OK` / `delete`→`HTTP_204_NO_CONTENT`
  mocking:```python
from unittest.mock import patch
@patch('apps.payments.services.stripe')
def test_pay(mock_stripe, client, user, product):
    mock_stripe.Charge.create.return_value = {'id': 'ch_123', 'status': 'succeeded', 'amount': 9999} # or .side_effect = Exception('Card declined')
    client.force_login(user)
    resp = client.post(reverse('payments:process'), {'product_id': product.id, 'token': 'tok_visa'})
    assert resp.status_code == 302; mock_stripe.Charge.create.assert_called_once()
```
  email:```python
from django.core import mail
from django.test import override_settings
@override_settings(EMAIL_BACKEND='django.core.mail.backends.locmem.EmailBackend')
def test_email(db, order):
    order.send_confirmation_email()
    assert len(mail.outbox) == 1 and order.user.email in mail.outbox[0].to and 'Order Confirmation' in mail.outbox[0].subject
```
  integration_e2e:register→login→browse(`response.content.decode()`)→cart_add→checkout_review→`with patch('apps.checkout.services.process_payment')`→complete→assert `Order.objects.filter(...).exists()`;
  ref_map:{`@pytest.mark.django_db`:DB_access, `client`:Django_client, `api_client`:DRF_APIClient, `factory.create_batch(n)`:bulk_create, `patch('mod.fn')`:mock_ext, `override_settings`:temp_settings, `force_authenticate()`:bypass_DRF_auth, `assertRedirects`:302_check, `assertTemplateUsed`:template_check, `mail.outbox`:captured_emails}
}

§R{
  DO:{factories>manual_create, 1_assert/test, descriptive_name(`test_user_cannot_delete_others_post`), edge_cases(empty,`None`,bounds), mock_ext_services, fixtures>duplication, test_permissions, speed(`--reuse-db`∧`--nomigrations`), tests=executable_docs};
  ANTI:{¬test_django_internals, ¬test_3rd_party, ¬ignore_failures, ¬order_dependent_tests, ¬over_mock(ext_only), ¬test_private_methods(public_iface_only), ¬prod_db}
}

§COV{
  cmd:`pytest --cov=apps --cov-report=html --cov-report=term-missing` ∧ `open htmlcov/index.html`;
  targets:{Models:≥90%, Serializers:≥85%, Views:≥80%, Services:≥90%, Utilities:≥80%, Overall:≥80%}
}

§CHK{
  loop_rule:sequential(P1..P9)∧(fail⇒STOP∧fix_before_continue)∧(manual_review∧staging_test_still_req);
  P1_env:`python --version && which python && pip list --outdated && python -c "import os; print('DJANGO_SECRET_KEY set' if os.environ.get('DJANGO_SECRET_KEY') else 'MISSING: DJANGO_SECRET_KEY')"`
  P2_quality:`mypy . --config-file pyproject.toml && ruff check . && ruff format --check . && python manage.py check --deploy` # alt: `black . --check`, `isort . --check-only` (skip if ruff sorts)
  P3_migrations:`python manage.py showmigrations && python manage.py makemigrations --check --dry-run && python manage.py migrate --plan` # report: pending_count, conflicts, unmigrated_model_Δ
  P4_tests:`pytest --cov=apps --cov-report=term-missing --reuse-db && pytest -m "not slow" && pytest -m integration` # report: passed/failed/skipped, overall+per-app_cov vs §COV.targets
  P5_security:`pip-audit && bandit -r apps -f json -o bandit-report.json && python manage.py check --deploy` # + `gitleaks detect --source . --verbose` if installed
  P6_runtime:`python manage.py collectstatic --noinput --dry-run && python manage.py check --database default && python -c "import django; django.setup(); from django.core.cache import cache; cache.set('healthcheck','ok',10); print(cache.get('healthcheck'))"` ∧ check N+1(DebugToolbar∨`assertNumQueries`)
  P7_prod_settings(prod_settings_mod):```python
from django.conf import settings
checks = {
    'DEBUG is False': not settings.DEBUG,
    'SECRET_KEY set': bool(settings.SECRET_KEY and len(settings.SECRET_KEY) > 30),
    'ALLOWED_HOSTS set': len(settings.ALLOWED_HOSTS) > 0,
    'HTTPS redirect': getattr(settings, 'SECURE_SSL_REDIRECT', False),
    'HSTS enabled': getattr(settings, 'SECURE_HSTS_SECONDS', 0) > 0,
    'Not SQLite': settings.DATABASES['default']['ENGINE'] != 'django.db.backends.sqlite3',
}
for k, ok in checks.items(): print(('PASS ' if ok else 'FAIL ') + k)
```
  P8_drf_schema:`python manage.py generateschema --format openapi-json > schema.json && python -c "import json; json.load(open('schema.json'))"`
  P9_diff:`git diff --stat && git diff | grep -nE "print\(|breakpoint\(|import pdb|DEBUG = True"` ∧ assert{¬debug_stmts, ¬hardcoded_secrets, migrations_for_model_Δ, ext_call_err_handling, atomic_tx_for_multi_write};
  report_tpl:`DJANGO VERIFICATION REPORT` → `{Environment, Code quality, Migrations, Tests, Security, Runtime, Settings, Diff}: PASS|FAIL <detail>` → `RESULT: PASS | BLOCKED - <remediation>`;
  pre_deploy:[tests_pass∧cov≥80%, ¬vuln_deps, ¬unapplied_migrations, `DEBUG=False`∧`SECRET_KEY`∧`ALLOWED_HOSTS`∈env, db_backups, static_collected_served, logging+err_monitor(Sentry), cache+Celery_workers(if_used), HTTPS];
  ci_gh_actions:```yaml
name: Django Verification
on: [push, pull_request]
jobs:
  verify:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16
        env: {POSTGRES_PASSWORD: postgres}
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: {python-version: '3.12', cache: pip}
      - run: pip install -r requirements.txt ruff mypy pytest pytest-django pytest-cov bandit pip-audit
      - run: ruff check . && ruff format --check . && mypy . && bandit -r apps && pip-audit
      - env: {DATABASE_URL: 'postgres://postgres:postgres@localhost:5432/postgres', DJANGO_SECRET_KEY: ci-only-secret-key}
        run: python manage.py makemigrations --check --dry-run && pytest --cov=apps --cov-report=term-missing
```
}
