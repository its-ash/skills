@REF:django-celery
SCOPE:Django+Celery_5.7(Redis|RabbitMQ)⇒bg_jobs,Beat,slow_ops(email,PDF,API),retry/DLQ,tests

§D{
  simple_offload_Django_6.0+⇒`django.tasks`(`@task`,`.enqueue()`,ecosystem_DB/broker_worker_backend)¬overkill_Celery_cluster;
  complex_pipelines(chains,chords,Beat,multi-queue_QoS,rate_limits,DLQ)⇒Celery_5.7+Redis|RabbitMQ
}

§CMD{
  install:`uv add "celery[redis]" django-celery-results django-celery-beat`(⊕`pip install 'celery[redis]' ...`);
  dev:`celery -A config worker --loglevel=info`;
  beat:`celery -A config beat --loglevel=info --scheduler django_celery_beat.schedulers:DatabaseScheduler`;
  dev_combo(¬prod):`celery -A config worker --beat --loglevel=info`;
  prod:`celery -A config worker --loglevel=warning --concurrency=4 -Q default,high_priority`;
  inspect:`celery -A config inspect active|stats|reserved`;
  q_len:`redis-cli llen celery`;
  flower:`uv add flower && celery -A config flower --port=5555`
}

§CFG{
  config/celery.py:os.environ.setdefault('DJANGO_SETTINGS_MODULE','config.settings.development'); app=Celery('myproject'); app.config_from_object('django.conf:settings',namespace='CELERY'); app.autodiscover_tasks()(tasks.py/app); @app.task(bind=True,ignore_result=True) def debug_task(self): print(f'Request: {self.request!r}');
  config/__init__.py:from .celery import app as celery_app; __all__=('celery_app',);
  config/settings/base.py:CELERY_BROKER_URL=env('CELERY_BROKER_URL',default='redis://localhost:6379/0'); CELERY_RESULT_BACKEND=env('CELERY_RESULT_BACKEND',default='django-db'); CELERY_ACCEPT_CONTENT=['json']; CELERY_TASK_SERIALIZER=CELERY_RESULT_SERIALIZER='json'; CELERY_TASK_TRACK_STARTED=True; CELERY_TASK_TIME_LIMIT=1800(30m); CELERY_TASK_SOFT_TIME_LIMIT=1500(25m→SoftTimeLimitExceeded); CELERY_WORKER_PREFETCH_MULTIPLIER=1(¬hoard); CELERY_TASK_ACKS_LATE=True(crash_requeue); CELERY_RESULT_EXPIRES=86400(24h); CELERY_BEAT_SCHEDULER='django_celery_beat.schedulers:DatabaseScheduler'; INSTALLED_APPS+=['django_celery_results','django_celery_beat']
}

§PAT{
  basic:@shared_task(name='notifications.send_welcome_email') def send_welcome_email(user_id:int)->None: User.objects.get(pk=user_id) except User.DoesNotExist: warn+return(idempotent)→EmailService.send_welcome(user);
  retry:@shared_task(bind=True,name='integrations.sync_to_crm',max_retries=5,default_retry_delay=60,autoretry_for=(ConnectionError,TimeoutError),retry_backoff=True,retry_backoff_max=600,retry_jitter=True) def sync_contact_to_crm(self,contact_id:int)->dict: try CRMClient().sync(contact_id) except CRMClient.RateLimitError as e: raise self.retry(exc=e,countdown=int(e.retry_after));
  idempotent_upd:updated=Order.objects.filter(pk=order_id,status=Order.Status.PROCESSING).update(status=Order.Status.SHIPPED,tracking_number=tracking_number); if ¬updated: log_info;
  soft_timeout(celery.exceptions.SoftTimeLimitExceeded):@shared_task(bind=True,name='reports.generate_pdf',soft_time_limit=120,time_limit=150) def generate_pdf_report(self,report_id:int)->str: try PDFGenerator.build(report_id) except SoftTimeLimitExceeded: PDFGenerator.cleanup(report_id); raise
}

§API{
  async:send_welcome_email.delay(user.pk);
  countdown:send_reminder.apply_async(args=[user.pk],countdown=3600);
  eta:send_reminder.apply_async(args=[user.pk],eta=timezone.now()+timedelta(days=1));
  queue:sync_contact_to_crm.apply_async(args=[contact.pk],queue='high_priority');
  sync(test/debug):generate_pdf_report.apply(args=[report.pk])
}

§SCH{
  code(CELERY_BEAT_SCHEDULE,celery.schedules.crontab):{'cleanup-expired-sessions':{'task':'users.cleanup_expired_sessions','schedule':crontab(hour=2,minute=0)},'sync-inventory':{'task':'products.sync_inventory','schedule':60.0},'weekly-digest':{'task':'notifications.send_weekly_digest','schedule':crontab(day_of_week='monday',hour=8,minute=0)}};
  db(django_celery_beat.models.{PeriodicTask,CrontabSchedule}):s,_=CrontabSchedule.objects.get_or_create(hour='*/6',minute='0',timezone='UTC'); PeriodicTask.objects.update_or_create(name='Sync inventory',defaults={'crontab':s,'task':'products.sync_inventory','args':json.dumps([]),'enabled':True})
}

§CNV{
  celery.{chain,group,chord}:
  seq:chain(fetch_data.s(source_id),transform_data.s(),load_to_warehouse.s()).delay()(prev→arg1);
  par:group(send_welcome_email.s(uid) for uid in new_user_ids).delay();
  map_red:chord(group(process_chunk.s(c) for c in data_chunks),aggregate_results.s()).delay()(cb(list))
}

§ERR{
  sentry(@task_failure.connect,celery.signals.task_failure):(sender,task_id,exception,args,kwargs,traceback,einfo,**kw)→with sentry_sdk.new_scope() as s: s.set_context('celery',{'task':sender.name,'task_id':task_id,'args':args,'kwargs':kwargs}); sentry_sdk.capture_exception(exception);
  dlq(@shared_task(bind=True,max_retries=3,name='payments.charge_card')):except Exception as e→if self.request.retries>=self.max_retries: FailedCharge.objects.create(order_id=order_id,error=str(e),task_id=self.request.id); return | else raise self.retry(exc=e)
}

§TST{
  unit(no_broker,@pytest.mark.django_db):send_welcome_email(user.pk) w/ patch('apps.notifications.services.EmailService')→assert_called_once_with(user); send_welcome_email(99999)⇒¬raise;
  eager(config/settings/test.py):CELERY_TASK_ALWAYS_EAGER=True; CELERY_TASK_EAGER_PROPAGATES=True; client.post('/api/users/',...)→201+mock_assert;
  retry:patch('apps.crm.services.CRMClient.sync',side_effect=ConnectionError('timeout')) as m→pytest.raises(ConnectionError): sync_contact_to_crm.apply(args=[1],throw=True)→m.call_count==1(eager=1_try)
}

§ANTI{
  task.delay(user)(stale_ORM)⇒ALWAYS task.delay(user.pk);
  enqueue_inside_tx_without_`transaction.on_commit`⇒worker_misses_uncommitted_row;
  task.apply() in prod⇒blocks_request_thread;
  unguarded charge()/fulfill()⇒double_exec; FIX:order=Order.objects.select_for_update().get(pk=order_id); if order.status!=Order.Status.PENDING: return
}

§CHK{supervisord|systemd|K8s; ACKS_LATE=True; PREFETCH=1; -Q default,high_priority,low_priority; SOFT_TIME_LIMIT; `transaction.on_commit`; Sentry task_failure; Flower; Beat=SINGLE_node_ONLY}

§REL{django.md,django-testing.md,../../python/references/python-testing.md}
