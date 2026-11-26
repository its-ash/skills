@REF:serverless
§WHEN{on_demand_HTTP(REST|HTTP_API);async_queues_topics_orchestrations;pay_per_use+autoscale;AWS|Azure}
§AWS_NODE{
  // Node.js 20; init SDK outside handler; reuse single http.Agent
  ```js
  const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
  const { DynamoDBDocumentClient, GetCommand } = require('@aws-sdk/lib-dynamodb');
  const doc = DynamoDBDocumentClient.from(new DynamoDBClient({}));
  exports.handler = async (event, ctx) => {
    ctx.callbackWaitsForEmptyEventLoop = false;
    try {
      const b = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
      const r = await doc.send(new GetCommand({ TableName: process.env.TABLE_NAME, Key: { id: b.id } }));
      return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(r.Item) };
    } catch (e) { return { statusCode: e.statusCode || 500, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ error: e.message }) }; }
  };
  ```
}
§AWS_PY{
  ```python
  import os, json, logging, boto3
  log = logging.getLogger(); log.setLevel(logging.INFO)
  tbl = boto3.resource('dynamodb').Table(os.getenv('TABLE_NAME'))
  def handler(ev, ctx):
      try: return {'statusCode': 200, 'body': json.dumps(tbl.get_item(Key={'id': json.loads(ev.get('body') or '{}')['id']}).get('Item'))}
      except Exception as e: log.exception('Handler error'); return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
  ```
}
§AWS_SAM{
  // Prefer HTTP API (low latency/cost); AWSTemplateFormatVersion:'2010-09-09', Transform:AWS::Serverless-2016-10-31
  Globals.Function:{Runtime:nodejs20.x,Timeout:30,MemorySize:256,Environment.Variables.TABLE_NAME:!Ref ItemsTable};
  HttpApi(AWS::Serverless::HttpApi):{StageName:prod,CorsConfiguration:{AllowOrigins:['*'],AllowMethods:['GET','POST','DELETE'],AllowHeaders:['*']}};
  Functions(AWS::Serverless::Function):
    GetItem:{Handler:src/handlers/get.handler,Events:{Type:HttpApi,ApiId:!Ref HttpApi,Path:/items/{id},Method:GET},Policies:[DynamoDBReadPolicy:{TableName:!Ref ItemsTable}]};
    CreateItem:{Handler:src/handlers/create.handler,Events:{Type:HttpApi,ApiId:!Ref HttpApi,Path:/items,Method:POST},Policies:[DynamoDBCrudPolicy:{TableName:!Ref ItemsTable}]};
  ItemsTable(AWS::DynamoDB::Table):{AttributeDefinitions:[{id,S}],KeySchema:[{id,HASH}],BillingMode:PAY_PER_REQUEST};
  Output.ApiUrl:!Sub "https://${HttpApi}.execute-api.${AWS::Region}.amazonaws.com/prod"
}
§AWS_SQS{
  // Partial batch failure + DLQ (14d=1209600s)
  ProcessorFunction.Events.SQSEvent:{Type:SQS,Queue:!GetAtt ProcessingQueue.Arn,BatchSize:10,FunctionResponseTypes:[ReportBatchItemFailures]};
  ProcessingQueue(AWS::SQS::Queue):{VisibilityTimeout:180,RedrivePolicy:{deadLetterTargetArn:!GetAtt DeadLetterQueue.Arn,maxReceiveCount:3}};
  DeadLetterQueue(AWS::SQS::Queue):{MessageRetentionPeriod:1209600};
  ```js
  exports.handler = async (ev) => {
    const batchItemFailures = [];
    for (const r of ev.Records) {
      try { await processMessage(JSON.parse(r.body)); } catch { batchItemFailures.push({ itemIdentifier: r.messageId }); }
    }
    return { batchItemFailures };
  };
  ```
}
§AZ{
  // Isolated worker (.NET 8): separate proc, VNET, DI + IHttpClientFactory (named clients in Program.cs)
  ```csharp
  [Function("GetItem")]
  public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", Route = "items/{id}")] HttpRequestData req, string id) {
    var client = _clientFactory.CreateClient();
    var res = req.CreateResponse(System.Net.HttpStatusCode.OK);
    await res.WriteStringAsync($"{{\"id\":\"{id}\"}}"); return res;
  }
  ```
  // Durable JS: orchestrator MUST be replay-safe (¬side effects); side effects in activities
  `df.orchestrator(function*(ctx){ const r1 = yield ctx.df.callActivity('FetchData', ctx.bindingData.id); return yield ctx.df.callActivity('TransformData', r1); })`
  // Node.js v4 model: single async handler
  `export async function handler(ctx, req) { ctx.res = { status: 200, body: `Hello ${req.query.name || req.body?.name || 'world'}` }; }`
}
§ANTI{
  monolithic_lambda⇒pkg_bloat+slow_cold_start+¬indep_scale;
  whole_SDK_imports⇒pkg_bloat+mem+latency;
  sync_VPC_calls⇒ENI_multi_sec_cold_start+blocking_DNS_DB;
  Task.Result_Azure⇒thread_starvation+low_concurrency;
  per_req_HttpClient_Azure_NET⇒SocketException;
  in_proc_Azure_new⇒lang_lock+¬VNET_isolated_cold_start
}
§OPS{
  cold_start:log_INIT(CloudWatch_Logs|App_Insights)→raise_mem∨Provisioned_Concurrency(AWS)|Premium_plan(Azure);pkg<50MB_uncompressed;
  timeout:Lambda>max_exec;Azure_host.json.functionTimeout(Consumption_max=5min,Premium/Dedicated=higher);
  vpc:attach_only_if_needed;DynamoDB⇒PrivateLink|VPC_endpoint(¬NAT_latency);
  warmup:CloudWatch_Event|Azure_Timer_every_few_min(critical_paths);
  obs_sec:fine_grained_IAM|FuncApp_perms;JSON_logs+reqID;tune_AppInsights_sampling;explicit_CORS_origins_prod(¬*);API_keys|JWT|AzureAD;err_details_debug_only
}
§CHK{
  SDK_outside_handler|DI;callbackWaitsForEmptyEventLoop=false;pkg<50MB;HTTP_API|isolated_worker;least_priv_IAM;DLQ_SQS|ServiceBus;JSON_logs+reqID;monitor_INIT;¬sync_VPC;IHttpClientFactory|single_http.Agent;warmup_timer;CORS+auth;status_codes+safe_err
}
