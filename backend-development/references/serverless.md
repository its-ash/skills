# Serverless Applications (AWS & Azure)

Create lightweight, event‑driven services without managing servers. This skill covers the most common patterns, anti‑patterns and operational safeguards for AWS Lambda + API Gateway + SQS + DynamoDB and Azure Functions (isolated worker, Durable Functions, Node.js & Python models). Use it to design, code and deploy production‑grade serverless APIs and background processors.

## When to use
- You need HTTP endpoints that run on demand (REST or HTTP API). 
- You need asynchronous, decoupled processing (queues, topics, durable orchestrations). 
- You prefer pay‑per‑use pricing and automatic scaling. 
- You are targeting AWS or Azure cloud platforms.

---

## Patterns
### 1. AWS Lambda Handler (Node.js)
- Initialise SDK clients **outside** the handler to reuse connections across invocations.
- Set `context.callbackWaitsForEmptyEventLoop = false` to avoid waiting for the event loop to empty.
- Return an object compatible with API Gateway (`statusCode`, `headers`, `body`).

```javascript
// handler.js (Node.js 20)
const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, GetCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  try {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    const result = await docClient.send(new GetCommand({
      TableName: process.env.TABLE_NAME,
      Key: { id: body.id }
    }));
    return { statusCode: 200, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(result.Item) };
  } catch (err) {
    console.error('Error:', err);
    return { statusCode: err.statusCode || 500, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ error: err.message }) };
  }
};
```

### 2. AWS Lambda Handler (Python)
- Use the same reuse pattern with `boto3.resource` outside the function.
- Log with the standard library.

```python
import os, json, logging, boto3
logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.getenv('TABLE_NAME'))

def handler(event, context):
    try:
        body = json.loads(event.get('body') or '{}')
        response = table.get_item(Key={'id': body['id']})
        return {'statusCode': 200, 'body': json.dumps(response.get('Item'))}
    except Exception as e:
        logger.exception('Handler error')
        return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
```

### 3. API Gateway Integration (AWS SAM)
- Use **HTTP API** for low‑latency, cost‑effective endpoints.
- Declare functions and permissions in a single SAM template.

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Globals:
  Function:
    Runtime: nodejs20.x
    Timeout: 30
    MemorySize: 256
    Environment:
      Variables:
        TABLE_NAME: !Ref ItemsTable
Resources:
  HttpApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      StageName: prod
      CorsConfiguration:
        AllowOrigins: ['*']
        AllowMethods: ['GET','POST','DELETE']
        AllowHeaders: ['*']
  GetItemFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: src/handlers/get.handler
      Events:
        GetItem:
          Type: HttpApi
          Properties:
            ApiId: !Ref HttpApi
            Path: /items/{id}
            Method: GET
      Policies:
        - DynamoDBReadPolicy:
            TableName: !Ref ItemsTable
  CreateItemFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: src/handlers/create.handler
      Events:
        CreateItem:
          Type: HttpApi
          Properties:
            ApiId: !Ref HttpApi
            Path: /items
            Method: POST
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref ItemsTable
  ItemsTable:
    Type: AWS::DynamoDB::Table
    Properties:
      AttributeDefinitions:
        - AttributeName: id
          AttributeType: S
      KeySchema:
        - AttributeName: id
          KeyType: HASH
      BillingMode: PAY_PER_REQUEST
Outputs:
  ApiUrl:
    Value: !Sub "https://${HttpApi}.execute-api.${AWS::Region}.amazonaws.com/prod"
```

### 4. Event‑Driven SQS Pattern (AWS)
- Configure Lambda to poll SQS with **batch size** and **partial‑failure reporting**.
- Attach a dead‑letter queue (DLQ) for messages that exceed retry attempts.

```yaml
Resources:
  ProcessorFunction:
    Type: AWS::Serverless::Function
    Properties:
      Handler: src/handlers/processor.handler
      Events:
        SQSEvent:
          Type: SQS
          Properties:
            Queue: !GetAtt ProcessingQueue.Arn
            BatchSize: 10
            FunctionResponseTypes: [ReportBatchItemFailures]
  ProcessingQueue:
    Type: AWS::SQS::Queue
    Properties:
      VisibilityTimeout: 180
      RedrivePolicy:
        deadLetterTargetArn: !GetAtt DeadLetterQueue.Arn
        maxReceiveCount: 3
  DeadLetterQueue:
    Type: AWS::SQS::Queue
    Properties:
      MessageRetentionPeriod: 1209600
```

```javascript
// src/handlers/processor.js
exports.handler = async (event) => {
  const batchItemFailures = [];
  for (const record of event.Records) {
    try {
      const body = JSON.parse(record.body);
      await processMessage(body);
    } catch (err) {
      console.error(`Failed ${record.messageId}:`, err);
      batchItemFailures.push({ itemIdentifier: record.messageId });
    }
  }
  return { batchItemFailures };
};

async function processMessage(msg) {
  // Insert business logic here
  console.log('Processing', msg);
}
```

### 5. Azure Functions – Isolated Worker Model (.NET 8)
- Run each function in its own process for better cold‑start performance and VNET support.
- Use **dependency injection** and **IHttpClientFactory** to avoid socket exhaustion.

```csharp
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net.Http;

public class GetItemFunction
{
    private readonly ILogger _logger;
    private readonly IHttpClientFactory _clientFactory;
    public GetItemFunction(ILoggerFactory loggerFactory, IHttpClientFactory clientFactory)
    {
        _logger = loggerFactory.CreateLogger<GetItemFunction>();
        _clientFactory = clientFactory;
    }

    [Function("GetItem")]
    public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "get", Route = "items/{id}")] HttpRequestData req, string id)
    {
        _logger.LogInformation("Processing request for {Id}", id);
        var client = _clientFactory.CreateClient();
        // Call external service or Cosmos DB here
        var response = req.CreateResponse(System.Net.HttpStatusCode.OK);
        await response.WriteStringAsync($"{{ \"id\": \"{id}\" }}");
        return response;
    }
}
```

### 6. Azure Functions – Durable Functions Orchestration (JavaScript)
- Model long‑running workflows with **orchestrator** and **activity** functions.
- Use **replay‑safe** code; avoid side effects inside the orchestrator.

```javascript
// orchestrator.js
const df = require('durable-functions');
module.exports = df.orchestrator(function* (context) {
  const result1 = yield context.df.callActivity('FetchData', context.bindingData.id);
  const result2 = yield context.df.callActivity('TransformData', result1);
  return result2;
});
```

```javascript
// fetchData.js (activity)
module.exports = async function (context) {
  const { id } = context.bindingData;
  // Call external API or DB
  return { id, value: 'sample' };
};
```

### 7. Azure Functions – Node.js v4 Programming Model
- Export a single `handler` function.
- Use async/await for all I/O.

```javascript
export async function handler(context, req) {
  const name = req.query.name || (req.body && req.body.name) || 'world';
  context.res = { status: 200, body: `Hello ${name}` };
}
```

---

## Anti‑Patterns
| Pattern | Why it hurts |
|---------|--------------|
| **Monolithic Lambda** (large code base in one function) | Increases deployment package size, slows cold starts, makes independent scaling impossible. |
| **Large Dependencies** (importing whole SDKs when only a few calls are needed) | Bloats the package, raises memory usage, worsens latency. |
| **Synchronous Calls in VPC** (blocking DNS or database calls without async) | ENI attachment adds several seconds to cold start; blocking I/O further delays response. |
| **Blocking Async Calls in Azure Functions** (e.g., `Result` on a `Task`) | Prevents the runtime from releasing the thread, reduces concurrency. |
| **Creating `HttpClient` per request** (Azure .NET) | Exhausts sockets, leads to `SocketException` under load. |
| **In‑process model for new Azure projects** | Limits language version, prevents isolated worker benefits like VNET integration and better cold‑start isolation. |

---

## Sharp Edges & Mitigations
- **Cold start measurement**: Enable CloudWatch Logs (AWS) or Application Insights (Azure) and log the duration of the **INIT** phase. Increase memory allocation to reduce CPU‑bound init time.
- **Timeout configuration**: Set Lambda timeout slightly above the longest expected execution. For Azure Functions, configure `functionTimeout` in `host.json` (Consumption plan max 5 min, Premium/DEDICATED higher).
- **VPC configuration**: Attach Lambdas to VPC only when required. Use **AWS PrivateLink** or **VPC‑endpoint** for DynamoDB to avoid NAT latency.
- **Event loop handling**: In Node.js, set `context.callbackWaitsForEmptyEventLoop = false` to return early while background work continues.
- **Partial batch failure**: Return `batchItemFailures` from SQS‑triggered Lambdas to retry only failing records.
- **Warm‑up triggers**: Schedule a lightweight function (e.g., CloudWatch Event or Azure Timer) to invoke the main handler every few minutes, keeping containers warm.
- **IHttpClientFactory**: Register it in `Program.cs` for isolated worker apps. Use named clients for different external services.
- **Application Insights sampling**: Adjust sampling rate to capture enough telemetry without overwhelming the portal.
- **CORS**: Define explicit origins in API Gateway or Azure Function `cors` settings; avoid wildcard in production.

---

## Checklist
- [ ] Initialise SDK clients **outside** the handler (AWS) or use DI (Azure). 
- [ ] Set `callbackWaitsForEmptyEventLoop = false` (Node.js). 
- [ ] Keep function packages < 50 MB (uncompressed) to limit cold start. 
- [ ] Use **HTTP API** (AWS) or **isolated worker** (Azure) for new projects. 
- [ ] Define fine‑grained IAM roles or Function App permissions. 
- [ ] Configure dead‑letter queues for SQS or Service Bus. 
- [ ] Enable structured logging (JSON) and include request IDs. 
- [ ] Monitor init duration and adjust memory or provisioned concurrency (AWS) / Premium plan (Azure). 
- [ ] Avoid synchronous/blocking calls inside VPC‑attached functions. 
- [ ] Use `IHttpClientFactory` (Azure) or keep a single `http.Agent` (Node) to reuse connections. 
- [ ] Add a warm‑up timer trigger for critical latency paths. 
- [ ] Validate CORS and authentication (API keys, JWT, Azure AD). 
- [ ] Test error handling: return proper HTTP status codes and include error details only for debugging.
