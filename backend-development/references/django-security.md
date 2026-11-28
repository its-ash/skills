@REF:django-security
SCOPE:Django_6.1/6.0/5.2_LTS_authN/authZ,perms/RBAC,prod_cfg,native_CSP,SQLi/XSS/CSRF/upload,API_throttle,headers,env,logging,chk

§CFG{
  settings/production.py(django.core.exceptions.ImproperlyConfigured):
  DEBUG=False(CRITICAL:NEVER True in prod); ALLOWED_HOSTS=os.environ.get('ALLOWED_HOSTS','').split(','); SECURE_SSL_REDIRECT=SESSION_COOKIE_SECURE=CSRF_COOKIE_SECURE=True; SECURE_HSTS_SECONDS=31536000(1y); SECURE_HSTS_INCLUDE_SUBDOMAINS=SECURE_HSTS_PRELOAD=True; SECURE_CONTENT_TYPE_NOSNIFF=True; X_FRAME_OPTIONS='DENY'; SESSION_COOKIE_HTTPONLY=True; SESSION_COOKIE_SAMESITE=CSRF_COOKIE_SAMESITE='Lax'; SECRET_KEY=os.environ.get('DJANGO_SECRET_KEY')→if ¬SECRET_KEY: raise ImproperlyConfigured('DJANGO_SECRET_KEY environment variable is required');
  AUTH_PASSWORD_VALIDATORS(django.contrib.auth.password_validation.*):UserAttributeSimilarityValidator, MinimumLengthValidator(OPTIONS:{'min_length':12}), CommonPasswordValidator, NumericPasswordValidator
}

§AUTH{
  custom_user(apps/users/models.py, settings/base.py:AUTH_USER_MODEL='users.User'):User(AbstractUser) w/ email=models.EmailField(unique=True), phone=models.CharField(max_length=20,blank=True), USERNAME_FIELD='email', REQUIRED_FIELDS=['username'], Meta.db_table='users', __str__→self.email;
  hashers(Argon2_1st;¬legacy_PBKDF2SHA1):PASSWORD_HASHERS=['django.contrib.auth.hashers.Argon2PasswordHasher','django.contrib.auth.hashers.ScryptPasswordHasher','django.contrib.auth.hashers.PBKDF2PasswordHasher'];
  session:SESSION_ENGINE='django.contrib.sessions.backends.cache'(|'db'); SESSION_CACHE_ALIAS='default'; SESSION_COOKIE_AGE=604800(1wk); SESSION_SAVE_EVERY_REQUEST=False; SESSION_EXPIRE_AT_BROWSER_CLOSE=False(UX>strict_sec)
}

§AUTHZ{
  model_perms:Meta.permissions=[('can_publish','Can publish posts'),('can_edit_others','Can edit posts of others')]; check:user.has_perm('app.can_edit_others');
  cbv:PostUpdateView(LoginRequiredMixin,PermissionRequiredMixin,UpdateView)→permission_required='app.can_edit_others', raise_exception=True(403 ¬redirect), get_queryset()→Post.objects.filter(author=self.request.user);
  drf_perms(rest_framework.permissions.BasePermission):
    IsOwnerOrReadOnly.has_object_permission(req,view,obj)→req.method in SAFE_METHODS or obj.author==req.user;
    IsAdminOrReadOnly.has_permission(req,view)→req.method in SAFE_METHODS or (req.user and req.user.is_staff);
    IsVerifiedUser.has_permission(req,view)→req.user and req.user.is_authenticated and req.user.is_verified;
  rbac:User.Role(models.TextChoices):ADMIN='admin';MODERATOR='moderator';USER='user'; role=models.CharField(max_length=20,choices=Role,default=Role.USER); is_admin()→role==Role.ADMIN or is_superuser; is_moderator()→role in {Role.ADMIN,Role.MODERATOR}; AdminRequiredMixin.dispatch:if ¬req.user.is_authenticated ∨ ¬req.user.is_admin()→raise PermissionDenied(django.core.exceptions)
}

§SQLI{
  safe:ORM(get(username=u),filter(email__iexact=e),filter(Q(username__icontains=q)|Q(email__icontains=q))) ∨ param_raw('SELECT * FROM users WHERE email = %s AND status = %s',[email,status]);
  ANTI:User.objects.raw(f'SELECT * FROM users WHERE username = {username}')⇒VULNERABLE
}

§XSS{
  tpl:{{ user_input }}(auto-escaped); {{ trusted_html|safe }}(trusted_ONLY); |escape; |striptags; JS:{{ data|json_script:"app-data" }}(¬manual_escape_in_script)∨{{ username|escapejs }};
  py(django.utils.{safestring.mark_safe,html.{escape,format_html}}):ANTI mark_safe(user_input)⇒VULNERABLE | SAFE format_html('<span class="user">{}</span>',username)(auto-escapes args)
}

§HDR{
  cfg:SECURE_CONTENT_TYPE_NOSNIFF=True; X_FRAME_OPTIONS='DENY'; SECURE_REFERRER_POLICY='strict-origin-when-cross-origin'; ¬emit_`X-XSS-Protection: 1; mode=block`(deprecated,harmful;omit∨`0`);
  native_CSP(Django_6.0+):MIDDLEWARE+=['django.middleware.csp.ContentSecurityPolicyMiddleware']; TEMPLATES[0]['OPTIONS']['context_processors']+=['django.template.context_processors.csp'];
  ```python
  from django.utils.csp import CSP
  SECURE_CSP = {
      "default-src": [CSP.SELF],
      "script-src": [CSP.SELF, CSP.NONCE, "https://cdn.example.com"],
      "style-src": [CSP.SELF, CSP.NONCE],
      "img-src": [CSP.SELF, "data:", "https:"],
      "connect-src": [CSP.SELF, "https://api.example.com"],
      "frame-ancestors": [CSP.NONE],
  }
  # Rollout safely first via SECURE_CSP_REPORT_ONLY = {...}
  ```
  django5_2_LTS_fallback:use `django-csp` 4.x(`CONTENT_SECURITY_POLICY` dict + nonce middleware)¬hand-rolled_string_mw
}

§CSRF{
  cfg:CSRF_COOKIE_SECURE=True; CSRF_COOKIE_HTTPONLY=False(AJAX reads document.cookie; keep SESSION_COOKIE_HTTPONLY=True); CSRF_COOKIE_SAMESITE='Lax'; CSRF_TRUSTED_ORIGINS=['https://example.com'];
  tpl:<form method="post">{% csrf_token %}</form>;
  ajax:parse csrftoken from document.cookie(decodeURIComponent)→header 'X-CSRFToken':getCookie('csrftoken');
  exempt(django.views.decorators.csrf.csrf_exempt):@csrf_exempt ONLY when strictly needed(e.g. HMAC-verified external webhooks)
}

§UPL{
  allow:ALLOWED_MIMES={'image/jpeg','image/png','image/gif','application/pdf'}; MIME_TO_EXTENSIONS={'image/jpeg':{'.jpg','.jpeg'},'image/png':{'.png'},'image/gif':{'.gif'},'application/pdf':{'.pdf'}};
  validate_type:buf=value.read(2048); value.seek(0)→python-magic:mime=magic.from_buffer(buf,mime=True) | pure-Py(filetype,no libmagic):kind=filetype.guess(buf); mime=kind.mime if kind else None → mime not in ALLOWED_MIMES ∨ os.path.splitext(value.name)[1].lower() not in MIME_TO_EXTENSIONS.get(mime,set())⇒raise ValidationError(...);
  validate_size:value.size>5*1024*1024(5MB)⇒raise ValidationError(...);
  model:models.FileField(upload_to='documents/',validators=[validate_file_type,validate_file_size]);
  storage:MEDIA_ROOT='/var/www/media/'; MEDIA_URL='/media/'; MEDIA_DOMAIN='https://media.example.com'; ¬serve uploads directly→static:whitenoise|CDN; media:separate_server|S3
}

§API{
  throttle(REST_FRAMEWORK):DEFAULT_THROTTLE_CLASSES=rest_framework.throttling.[AnonRateThrottle,UserRateThrottle]; DEFAULT_THROTTLE_RATES={'anon':'100/day','user':'1000/day','upload':'10/hour'}; custom(UserRateThrottle):BurstRateThrottle(scope='burst',rate='60/min'), SustainedRateThrottle(scope='sustained',rate='1000/day');
  auth(REST_FRAMEWORK):DEFAULT_AUTHENTICATION_CLASSES=[rest_framework_simplejwt.authentication.JWTAuthentication,rest_framework.authentication.SessionAuthentication]; DEFAULT_PERMISSION_CLASSES=['rest_framework.permissions.IsAuthenticated']; FBV:@api_view(['GET','POST']) @permission_classes([IsAuthenticated])
}

§ENV{
  django-environ|python-decouple:env=environ.Env(DEBUG=(bool,False)); environ.Env.read_env(); SECRET_KEY=env('DJANGO_SECRET_KEY'); DATABASE_URL=env('DATABASE_URL'); ALLOWED_HOSTS=env.list('ALLOWED_HOSTS');
  .env(¬commit):DEBUG=False, SECRET_KEY=..., DATABASE_URL=postgresql://user:password@localhost:5432/dbname, ALLOWED_HOSTS=example.com,www.example.com
}

§LOG{
  LOGGING:version=1,disable_existing_loggers=False; handlers:file(WARNING,logging.FileHandler,/var/log/django/security.log), console(INFO,logging.StreamHandler); loggers:'django.security'(['file','console'],WARNING,propagate=True), 'django.request'(['file'],ERROR,propagate=False)
}

§CHK{
  DEBUG=False∧HTTPS_only(SSL_REDIRECT,secure_cookies)∧env_secrets∧Argon2_hasher∧AUTH_PASSWORD_VALIDATORS(min=12)∧CSRF_on∧XSS_autoescape(¬|safe/mark_safe)∧SQLi(ORM/param_raw)∧uploads(magic+ext+5MB+S3/CDN)∧API_throttle∧headers(native_CSP/`django-csp`,XFO,HSTS,nosniff,¬X-XSS-Protection)∧security_logging∧regular_updates/reviews
}
§REL{django.md,django-testing.md,../../secure-coding/SKILL.md}
