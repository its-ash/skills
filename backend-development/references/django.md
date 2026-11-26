@REF:django
§META{scope:Django_5.x;use:new_app∨refactor∨async∨DRF∨Celery∨Channels∨perf∨sec∨deploy}
§R{
  views:CBV_default∧FBV_simple_only;
  logic:views→services.py∨custom_Manager/QuerySet;
  queries:select_related(FK,1:1)∧prefetch_related(M2M,rev_FK)∧annotate()∧DB_index(filter,order,lookup);
  typing:type_hints+docstrings(∀public_fn);
  user:custom_User_model_before_first_migration;
  pkgs:stdlib/Django_builtin_first¬overuse_3p
}
§ARCH{
  layout:config/(settings/{base,development,production,test}.py,urls,wsgi,asgi.py)+apps/<feat>/{models,views,serializers,urls,permissions,filters,services}.py+tests/;
  cfg:django-environ;base.py(DEBUG=False,env(SECRET_KEY,DB));dev.py(from .base import *;DEBUG=True;debug_toolbar);prod.py(from .base import *;HTTPS,HSTS,env.list('ALLOWED_HOSTS'));
  3p_cfg:dedicated(celery.py,cache.py);
  repo:complex_query_abstraction_only_else_Manager
}
§ORM{
  chainable_qs:QuerySet_methods>Manager_one_offs⇒`objects = ProductQuerySet.as_manager()`;
  django5_1:CheckConstraint(condition=Q(...),name=...)¬check=;
  bulk:bulk_create(objs,batch_size=500)|bulk_update(objs,['f'],batch_size=500)|qs.update(...)⇒1_SQL_stmt∧SKIPS(save(),post_save);
  pg:JSONField,ArrayField,SearchVector;
  pool:django-db-pool∨PgBouncer;
  migrations:small∧group_related_changes
}
```python
class ProductQuerySet(models.QuerySet):
    def active(self): return self.filter(is_active=True)
    def in_stock(self): return self.filter(stock__gt=0)
    def with_relations(self): return self.select_related('category').prefetch_related('tags')
    def search(self, q: str): return self.filter(models.Q(name__icontains=q) | models.Q(description__icontains=q))

class Product(models.Model):
    name = models.CharField(max_length=200)
    slug = models.SlugField(unique=True, max_length=250)
    price = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    stock = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)
    category = models.ForeignKey('Category', on_delete=models.PROTECT, related_name='products')
    tags = models.ManyToManyField('Tag', blank=True, related_name='products')
    created_at, updated_at = models.DateTimeField(auto_now_add=True), models.DateTimeField(auto_now=True)
    objects = ProductQuerySet.as_manager()
    class Meta:
        ordering = ['-created_at']
        indexes = [models.Index(fields=['-created_at']), models.Index(fields=['category', 'is_active'])]
        constraints = [models.CheckConstraint(condition=models.Q(price__gte=0), name='price_non_negative')]  # <5.1: check=
    def save(self, *args, **kwargs):
        if not self.slug: self.slug = slugify(self.name)
        super().save(*args, **kwargs)
```
§TX{
  atomic:`@transaction.atomic`;
  ext_io:payment/email_outside_tx∨`transaction.on_commit(lambda: task.delay(pk))`
}
```python
@transaction.atomic
def create_order(user, cart) -> Order:
    order = Order.objects.create(user=user, total_price=cart.total_price)
    OrderItem.objects.bulk_create([OrderItem(order=order, product=i.product, quantity=i.quantity, price=i.product.price) for i in cart.items.select_related('product')])
    cart.items.all().delete()
    transaction.on_commit(lambda: send_order_confirmation.delay(order.pk))
    return order
```
§ASYNC{
  when:I/O_bound(httpx.AsyncClient)∧full_ASGI_stack;
  srv:uvicorn|daphne|hypercorn;
  ws:Channels(`AsyncJsonWebsocketConsumer`:connect→`channel_layer.group_add`+`accept()`,disconnect→`group_discard`,notify→`send_json(event['payload'])`);
  anti:mix_sync_async_without_adapter⇒thread_block
}
§DRF{
  crud:ModelViewSet+Router∧`perform_create`/`perform_update`→`serializer.save()`;
  auth:JWT(djangorestframework-simplejwt)∨OAuth2(django-oauth-toolkit);obj_perm:django-guardian;
  sec:explicit `fields` list¬`'__all__'`_on_sensitive_models;validate_password;write_only=True;create_user(**validated)
}
```python
class ProductSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    discount_price = serializers.SerializerMethodField()
    class Meta:
        model = Product
        fields = ['id', 'name', 'slug', 'price', 'discount_price', 'stock', 'category_name', 'created_at']
        read_only_fields = ['id', 'slug', 'created_at']
    def get_discount_price(self, obj):
        d = getattr(obj, 'discount', None)
        return obj.price * (1 - d.percent / 100) if d else obj.price

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.with_relations()
    permission_classes = [IsAuthenticated, IsOwnerOrReadOnly]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class, search_fields, ordering_fields = ProductFilter, ['name', 'description'], ['price', 'created_at', 'name']
    def get_serializer_class(self): return ProductCreateSerializer if self.action == 'create' else ProductSerializer
    def perform_create(self, s): s.save(created_by=self.request.user)
    @action(detail=True, methods=['post'])
    def purchase(self, request, pk=None): return Response(OrderSerializer(OrderService.purchase(self.get_object(), request.user)).data, status=status.HTTP_201_CREATED)
    @action(detail=False, methods=['get'])
    def mine(self, request):
        page = self.paginate_queryset(self.get_queryset().filter(created_by=request.user))
        return self.get_paginated_response(self.get_serializer(page, many=True).data)
```
§CELERY{
  broker:Redis|RabbitMQ;
  task:idempotent∧short(long→chain|chord);
  decorator:`@shared_task(bind=True, max_retries=3)`→`transaction.atomic`→`self.retry(exc=exc, countdown=60)`;
  sched:Celery_beat+Flower_monitor
}
§CACHE{
  view:`@method_decorator(cache_page(60*15), name='dispatch')`;
  val:`cache.get_or_set(key, fn, 60*15)`;
  tpl:`{% load cache %}{% cache 500 sidebar request.user.id %}...{% endcache %}`;
  inval:delete_or_rotate_key_on_write;ref:database-design/references/redis.md
}
§SIG_MW{
  signals:`@receiver(post_save, sender=User)`∧import_in_`AppConfig.ready()`(`# noqa: F401`)⇒non_core_side_effects_only(¬hide_business_flow);
  middleware:`__init__(get_response)`/`__call__(request)`(`time.perf_counter()`)⇒¬DB_write_per_req(throttle∨cache)
}
§SEC{
  mw:SecurityMiddleware,XContentTypeOptionsMiddleware,XFrameOptionsMiddleware;
  prod:SECURE_HSTS_SECONDS,SECURE_SSL_REDIRECT,SESSION_COOKIE_SECURE,ALLOWED_HOSTS(anti_host_header_atk);
  in:serializers/forms_validate_all¬trust_client;secrets:env/SecretsManager/Vault(¬commit,¬log);
  csrf:enforce_state_change(exempt_token_API_only);cors:trusted_origins_only
}
§TEST{
  stack:pytest-django(`@pytest.mark.django_db`)+factory_boy+APIClient+reverse();
  tiers:unit|integration|e2e;cov:`pytest --cov=yourapp`(≥85%);
  query_prof:django-silk∨assertNumQueries
}
§OPS{
  docker:multi_stage(build_deps→runtime_assets_only);
  files:static→WhiteNoise|CDN(`collectstatic`_req_prod);media→S3(django-storages)¬DB_blobs;
  srv:Gunicorn(WSGI)|Uvicorn(ASGI);logs:JSON(ELK/DataDog,¬secrets);
  ci:lint+test+sec_scan_per_push;docs:DRF_Spectacular(OpenAPI);perf:load_test+django-silk;
  fe:templates+HTMX|SPA(DRF+django-webpack-loader∨static_host)|SEO_SSR(Next.js)
}
§REL{
  django-celery.md:Celery_cfg,retries,beat,canvas,tests;
  django-security.md:prod_cfg,auth,perms,CSRF,XSS,SQLi,uploads,headers;
  django-testing.md:pytest-django,factory_boy,DRF_tests,verify_loop;
  ../../python/SKILL.md:Python_3.12+,async_vs_sync;
  ../SKILL.md:backend_API_arch;
  ../../database-design/references/database-optimization.md:SQL_tuning,indexes;
  ../../unit-testing-patterns/SKILL.md:pytest_patterns
}
