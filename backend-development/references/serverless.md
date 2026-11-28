@REF:serverless
§WHEN{on_demand_HTTP(REST|HTTP_API|edge);async_queues_topics_orchestrations;pay_per_use+autoscale;AWS_Lambda|Azure_Functions_v4|Cloudflare_Workers}
§AWS_NODE{
  # AWS Lambda Node.js 24 (`nodejs24.x`) or Node.js 22 (`nodejs22.x`) on Amazon Linux 2023 (ESM `.mjs` / `"type":"module"`; ¬EOL `nodejs20.x`); init SDK outside handler; AWS SDK v3 modular imports only; Lambda Durable Functions supported on `nodejs22.x`/`nodejs24.x`
```js
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand } from '@aws-sdk/lib-dynamodb';
const doc = DynamoDBDocumentClient.from(new DynamoDBClient({}));
export const handler = async (event, ctx) => {
  ctx.callbackWaitsForEmptyEventLoop = false;
  try {
    const id = event.pathParameters?.id ?? (typeof event.body === 'string' ? JSON.parse(event.body) : event.body)?.id;
    const r = await doc.send(new GetCommand({ TableName: process.env.TABLE_NAME, Key: { id } }));
    return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(r.Item ?? null) };
  } catch (e) { return { statusCode: e.statusCode || 500, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ error: 'Internal error' }) }; }
};
```
}
§AWS_PY{
  # AWS Lambda Python 3.14 (`python3.14`) or 3.13 (`python3.13`) on Amazon Linux 2023 (Durable Functions supported); init boto3 outside handler
```python
import os, json, logging, boto3
log = logging.getLogger(); log.setLevel(logging.INFO)
tbl = boto3.resource('dynamodb').Table(os.getenv('TABLE_NAME'))
def handler(ev, ctx):
    try: return {'statusCode': 200, 'body': json.dumps(tbl.get_item(Key={'id': json.loads(ev.get('body') or '{}')['id']}).get('Item'))}
    except Exception: log.exception('Handler error'); return {'statusCode': 500, 'body': json.dumps({'error': 'Internal error'})}
```
}
§AWS_SAM{
  # Prefer HTTP API (low latency/cost); AWSTemplateFormatVersion:'2010-09-09', Transform:AWS::Serverless-2016-10-31
  Globals.Function:{Runtime:nodejs24.x,Architectures:[arm64],Timeout:30,MemorySize:256,Environment.Variables.TABLE_NAME:!Ref ItemsTable};
  HttpApi(AWS::Serverless::HttpApi):{StageName:prod,CorsConfiguration:{AllowOrigins:['https://app.example.com'],AllowMethods:['GET','POST','DELETE'],AllowHeaders:['Authorization','Content-Type']}};
  Functions(AWS::Serverless::Function):
    GetItem:{Handler:src/handlers/get.handler,Events:{Type:HttpApi,ApiId:!Ref HttpApi,Path:/items/{id},Method:GET},Policies:[DynamoDBReadPolicy:{TableName:!Ref ItemsTable}]};
    CreateItem:{Handler:src/handlers/create.handler,Events:{Type:HttpApi,ApiId:!Ref HttpApi,Path:/items,Method:POST},Policies:[DynamoDBCrudPolicy:{TableName:!Ref ItemsTable}]};
  ItemsTable(AWS::DynamoDB::Table):{AttributeDefinitions:[{id,S}],KeySchema:[{id,HASH}],BillingMode:PAY_PER_REQUEST};
  Output.ApiUrl:!Sub "https://${HttpApi}.execute-api.${AWS::Region}.amazonaws.com/prod"
}
§AWS_SQS{
  # Partial batch failure + DLQ (14d=1209600s)
  ProcessorFunction.Events.SQSEvent:{Type:SQS,Queue:!GetAtt ProcessingQueue.Arn,BatchSize:10,FunctionResponseTypes:[ReportBatchItemFailures]};
  ProcessingQueue(AWS::SQS::Queue):{VisibilityTimeout:180,RedrivePolicy:{deadLetterTargetArn:!GetAtt DeadLetterQueue.Arn,maxReceiveCount:3}};
  DeadLetterQueue(AWS::SQS::Queue):{MessageRetentionPeriod:1209600};
```js
export const handler = async (ev) => {
  const batchItemFailures = [];
  for (const r of ev.Records) {
    try { await processMessage(JSON.parse(r.body)); } catch { batchItemFailures.push({ itemIdentifier: r.messageId }); }
  }
  return { batchItemFailures };
};
```
}
§AZ{
  # Azure Functions v4: .NET 10 LTS isolated worker (in-proc phased out; Flex Consumption|Premium|Dedicated for .NET 10) + DI + IHttpClientFactory
```csharp
[Function("GetItem")]
public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", Route = "items/{id}")] HttpRequestData req, string id) {
  var client = _clientFactory.CreateClient("upstream");
  var res = req.CreateResponse(System.Net.HttpStatusCode.OK);
  await res.WriteAsJsonAsync(new { id }); return res;
}
```
  # Azure Functions Node.js v4 programming model (`@azure/functions`: `app.http()`, return response object; ¬legacy v3 `ctx.res`)
```ts
import { app, HttpRequest, HttpResponseInit, InvocationContext } from '@azure/functions';
app.http('getItem', {
  methods: ['GET'], route: 'items/{id}', authLevel: 'function',
  handler: async (req: HttpRequest, ctx: InvocationContext): Promise<HttpResponseInit> => ({ status: 200, jsonBody: { id: req.params.id } }),
});
```
  # Durable JS (v4): orchestrator MUST be replay-safe (¬side effects/Date.now/Math.random); side effects in activities only
  `df.app.orchestration('flow', function*(ctx){ const r1 = yield ctx.df.callActivity('FetchData', ctx.df.getInput()); return yield ctx.df.callActivity('TransformData', r1); })`
}
§CF_WORKERS{
  # Cloudflare Workers: V8 isolates (~0ms cold start), Web Standard Fetch API + Hono, `wrangler.jsonc` (`compatibility_flags: ["nodejs_compat"]` for Node APIs), bindings:{D1(SQLite),KV,R2(object),Queues,Durable_Objects(stateful/WS),Hyperdrive(PG_pool)}
```ts
import { Hono } from 'hono';
type Bindings = { DB: D1Database; CACHE: KVNamespace; JOBS: Queue };
const app = new Hono<{ Bindings: Bindings }>();
app.get('/items/:id', async (c) => {
  const row = await c.env.DB.prepare('SELECT id, name FROM items WHERE id = ?').bind(c.req.param('id')).first();
  return row ? c.json({ data: row }) : c.json({ error: 'Not found' }, 404);
});
export default { fetch: app.fetch, async queue(batch: MessageBatch, env: Bindings) { for (const m of batch.messages) { await processMsg(m.body, env); m.ack(); } } };
```
}
§ANTI{
  EOL_runtimes(`nodejs20.x`,Azure_v3_Linux,Azure_in_proc_.NET);
  monolithic_lambda⇒pkg_bloat+slow_cold_start+¬indep_scale;
  whole_SDK_imports⇒pkg_bloat+mem+latency;
  sync_VPC_calls⇒ENI_cold_start+NAT_latency;
  Task.Result_Azure⇒thread_starvation+low_concurrency;
  per_req_HttpClient_Azure_NET⇒SocketException;
  v3_Azure_JS_`ctx.res`_in_v4_model;
  returning_raw_`e.message`_in_500_responses
}
§OPS{
  cold_start:arm64_Graviton+log_INIT(CloudWatch_Logs|App_Insights)→raise_mem∨Provisioned_Concurrency(AWS)|Flex_Consumption/Premium(Azure);pkg<50MB_uncompressed;
  timeout:Lambda>max_exec;Azure_host.json.functionTimeout(Consumption_max=5min,Flex/Premium=higher);CF_Workers_CPU_limits(offload_heavy_to_Queues);
  vpc:attach_only_if_needed;DynamoDB/S3⇒VPC_Gateway_Endpoint(¬NAT_cost/latency);
  obs_sec:fine_grained_IAM|Managed_Identity|scoped_bindings;JSON_logs+reqID;tune_AppInsights_sampling;explicit_CORS_origins_prod(¬`*`);API_keys|JWT|Entra_ID;err_details_debug_only
}
§CHK{
  current_runtime(`nodejs24.x`/`python3.14`/`.NET 10`/CF_Workers);SDK_outside_handler|DI;callbackWaitsForEmptyEventLoop=false;pkg<50MB;HTTP_API|isolated_worker|Hono;least_priv_IAM;DLQ_SQS|ServiceBus|CF_Queues;JSON_logs+reqID;monitor_INIT;¬sync_VPC;IHttpClientFactory|single_http.Agent;CORS+auth;status_codes+safe_err
}
§REL{../SKILL.md,nodejs-patterns.md,../../devops-iac/references/cloudflare-deploy.md,../../devops-iac/references/cloud-architecture.md}
