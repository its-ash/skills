@REF:django-security
SCOPE:Django_authN/authZ,perms/RBAC,prod_cfg,SQLi/XSS/CSRF/upload,API_throttle,headers,env,logging,chk

§CFG{
settings/production.py(django.core.exceptions.ImproperlyConfigured):
DEBUG=False(CRITICAL:NEVER True in prod); ALLOWED_HOSTS=os.environ.get('ALLOWED_HOSTS','').split(','); SECURE_SSL_REDIRECT=SESSION_COOKIE_SECURE=CSRF_COOKIE_SECURE=True; SECURE_HSTS_SECONDS=31536000(1y); SECURE_HSTS_INCLUDE_SUBDOMAINS=SECURE_HSTS_PRELOAD=True; SECURE_CONTENT_TYPE_NOSNIFF=True; X_FRAME_OPTIONS='DENY'; SESSION_COOKIE_HTTPONLY=True; SESSION_COOKIE_SAMESITE=CSRF_COOKIE_SAMESITE='Lax'; SECRET_KEY=os.environ.get('DJANGO_SECRET_KEY')→if ¬SECRET_KEY: raise ImproperlyConfigured('DJANGO_SECRET_KEY environment variable is required')
AUTH_PASSWORD_VALIDATORS(django.contrib.auth.password_validation.*):UserAttributeSimilarityValidator, MinimumLengthValidator(OPTIONS:{'min_length':12}), CommonPasswordValidator, NumericPasswordValidator
}

§AUTH{
custom_user(apps/users/models.py, settings/base.py:AUTH_USER_MODEL='users.User'):User(AbstractUser) w/ email=models.EmailField(unique=True), phone=models.CharField(max_length=20,blank=True), USERNAME_FIELD='email', REQUIRED_FIELDS=['username'], Meta.db_table='users', __str__→self.email
hashers(default=PBKDF2;stronger):PASSWORD_HASHERS=django.contrib.auth.hashers.[Argon2PasswordHasher,PBKDF2PasswordHasher,PBKDF2SHA1PasswordHasher,BCryptSHA256PasswordHasher]
session:SESSION_ENGINE='django.contrib.sessions.backends.cache'(|'db'); SESSION_CACHE_ALIAS='default'; SESSION_COOKIE_AGE=604800(1wk); SESSION_SAVE_EVERY_REQUEST=False; SESSION_EXPIRE_AT_BROWSER_CLOSE=False(UX>strict_sec)
}

§AUTHZ{
model_perms:Meta.permissions=[('can_publish','Can publish posts'),('can_edit_others','Can edit posts of others')]; check:user.has_perm('app.can_edit_others')
cbv:PostUpdateView(LoginRequiredMixin,PermissionRequiredMixin,UpdateView)→permission_required='app.can_edit_others', raise_exception=True(403 ¬redirect), get_queryset()→Post.objects.filter(author=self.request.user)
drf_perms(rest_framework.permissions.BasePermission):
- IsOwnerOrReadOnly.has_object_permission(req,view,obj)→req.method in SAFE_METHODS or obj.author==req.user
- IsAdminOrReadOnly.has_permission(req,view)→req.method in SAFE_METHODS or (req.user and req.user.is_staff)
- IsVerifiedUser.has_permission(req,view)→req.user and req.user.is_authenticated and req.user.is_verified
rbac:User.ROLE_CHOICES=[('admin','Administrator'),('moderator','Moderator'),('user','Regular User')]; role=models.CharField(max_length=20,choices=ROLE_CHOICES,default='user'); is_admin()→role=='admin' or is_superuser; is_moderator()→role in ['admin','moderator']; AdminRequiredMixin.dispatch:if ¬req.user.is_authenticated ∨ ¬req.user.is_admin()→raise PermissionDenied(django.core.exceptions)
}

§SQLI{
safe:ORM(get(username=u),filter(email__iexact=e),filter(Q(username__icontains=q)|Q(email__icontains=q))) ∨ param_raw('SELECT * FROM users WHERE email = %s AND status = %s',[email,status])
ANTI:User.objects.raw(f'SELECT * FROM users WHERE username = {username}')⇒VULNERABLE
}

§XSS{
tpl:{{ user_input }}(auto-escaped); {{ trusted_html|safe }}(trusted_ONLY); |escape; |striptags; JS:{{ username|escapejs }}
py(django.utils.{safestring.mark_safe,html.{escape,format_html}}):ANTI mark_safe(user_input)⇒VULNERABLE | SAFE mark_safe(escape(user_input)) ∨ format_html('<span class="user">{}</span>',escape(username))
}

§HDR{
cfg:SECURE_CONTENT_TYPE_NOSNIFF=True; X_FRAME_OPTIONS='DENY'
SecurityHeaderMiddleware:X-Content-Type-Options:'nosniff', X-Frame-Options:'DENY', X-XSS-Protection:'1; mode=block', Content-Security-Policy:"default-src 'self'"
CSPMiddleware+cfg:CSP_DEFAULT_SRC="'self'", CSP_SCRIPT_SRC="'self' https://cdn.example.com", CSP_STYLE_SRC="'self' 'unsafe-inline'", CSP_IMG_SRC="'self' data: https:", CSP_CONNECT_SRC="'self' https://api.example.com"→f"default-src {CSP_DEFAULT_SRC}; script-src {CSP_SCRIPT_SRC}; style-src {CSP_STYLE_SRC}; img-src {CSP_IMG_SRC}; connect-src {CSP_CONNECT_SRC}"
}

§CSRF{
cfg:CSRF_COOKIE_SECURE=True; CSRF_COOKIE_HTTPONLY=False(AJAX reads document.cookie; keep SESSION_COOKIE_HTTPONLY=True); CSRF_COOKIE_SAMESITE='Lax'; CSRF_TRUSTED_ORIGINS=['https://example.com']
tpl:<form method="post">{% csrf_token %}</form>
ajax:parse csrftoken from document.cookie(decodeURIComponent)→header 'X-CSRFToken':getCookie('csrftoken')
exempt(django.views.decorators.csrf.csrf_exempt):@csrf_exempt ONLY when strictly needed(e.g. external webhooks)
}

§UPL{
allow:ALLOWED_MIMES={'image/jpeg','image/png','image/gif','application/pdf'}; MIME_TO_EXTENSIONS={'image/jpeg':{'.jpg','.jpeg'},'image/png':{'.png'},'image/gif':{'.gif'},'application/pdf':{'.pdf'}}
validate_type:buf=value.read(2048); value.seek(0)→python-magic:mime=magic.from_buffer(buf,mime=True) | pure-Py(filetype,no libmagic):kind=filetype.guess(buf); mime=kind.mime if kind else None → mime not in ALLOWED_MIMES ∨ os.path.splitext(value.name)[1].lower() not in MIME_TO_EXTENSIONS.get(mime,set())⇒raise ValidationError(...)
validate_size:value.size>5*1024*1024(5MB)⇒raise ValidationError(...)
model:models.FileField(upload_to='documents/',validators=[validate_file_type,validate_file_size])
storage:MEDIA_ROOT='/var/www/media/'; MEDIA_URL='/media/'; MEDIA_DOMAIN='https://media.example.com'; ¬serve uploads directly→static:whitenoise|CDN; media:separate_server|S3
}

§API{
throttle(REST_FRAMEWORK):DEFAULT_THROTTLE_CLASSES=rest_framework.throttling.[AnonRateThrottle,UserRateThrottle]; DEFAULT_THROTTLE_RATES={'anon':'100/day','user':'1000/day','upload':'10/hour'}; custom(UserRateThrottle):BurstRateThrottle(scope='burst',rate='60/min'), SustainedRateThrottle(scope='sustained',rate='1000/day')
auth(REST_FRAMEWORK):DEFAULT_AUTHENTICATION_CLASSES=[rest_framework.authentication.{TokenAuthentication,SessionAuthentication},rest_framework_simplejwt.authentication.JWTAuthentication]; DEFAULT_PERMISSION_CLASSES=['rest_framework.permissions.IsAuthenticated']; FBV:@api_view(['GET','POST']) @permission_classes([IsAuthenticated])
}

§ENV{
python-decouple|django-environ:env=environ.Env(DEBUG=(bool,False)); environ.Env.read_env(); SECRET_KEY=env('DJANGO_SECRET_KEY'); DATABASE_URL=env('DATABASE_URL'); ALLOWED_HOSTS=env.list('ALLOWED_HOSTS')
.env(¬commit):DEBUG=False, SECRET_KEY=..., DATABASE_URL=postgresql://user:password@localhost:5432/dbname, ALLOWED_HOSTS=example.com,www.example.com
}

§LOG{
LOGGING:version=1,disable_existing_loggers=False; handlers:file(WARNING,logging.FileHandler,/var/log/django/security.log), console(INFO,logging.StreamHandler); loggers:'django.security'(['file','console'],WARNING,propagate=True), 'django.request'(['file'],ERROR,propagate=False)
}

§CHK{
DEBUG=False∧HTTPS_only(SSL_REDIRECT,secure_cookies)∧env_secrets∧AUTH_PASSWORD_VALIDATORS(min=12)∧CSRF_on∧XSS_autoescape(¬|safe/mark_safe)∧SQLi(ORM/param_raw)∧uploads(magic+ext+5MB+S3/CDN)∧API_throttle∧headers(CSP,XFO,HSTS,nosniff)∧security_logging∧regular_updates/reviews
}
