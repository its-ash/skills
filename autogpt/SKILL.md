---
name: autogpt
description: "AutoGPT is a platform for building, deploying, and managing continuous autonomous AI agents through a visual workflow editor or code-first toolkit with Docker-based deployment and graph-based architecture. Use when creating persistent agents, multi-step AI pipelines, webhook-driven automation, scheduled cron executions, or manual HTTP-triggered workflows; involves graphs, nodes, blocks, visual builder, execution triggers, monitoring, Docker containerization, and agent orchestration."
---

# AutoGPT – Autonomous AI Agent Platform

AutoGPT lets you create, run, and monitor autonomous AI agents. Agents are defined as node‑based graphs that can be built with a drag‑and‑drop UI or with Python code via the Forge toolkit.

## When to use AutoGPT
- You need an agent that runs continuously or on a schedule.
- You prefer a visual, low‑code workflow builder.
- Your automation requires external triggers such as webhooks.
- You want to reuse or share modular blocks (LLM calls, integrations, decision logic).
- You need built‑in benchmarking and monitoring.

## Quick start (Docker)
```bash
# Clone repository
git clone https://github.com/Significant-Gravitas/AutoGPT.git
cd AutoGPT/autogpt_platform

# Prepare environment file
cp .env.example .env

# Build and start services
docker compose up -d --build
```

### Access the platform
- Frontend UI: <http://localhost:3000>
- Backend API: <http://localhost:8006/api>
- WebSocket for live updates: `ws://localhost:8001/ws`

## Architecture overview
- **Frontend** – React visual builder.
- **Backend** – FastAPI execution engine.
- **Infrastructure** – PostgreSQL, Redis, RabbitMQ.
- **Classic mode** – Forge toolkit, CLI, benchmark suite.

## Core concepts
### Graphs and nodes
An agent is a **graph** of **nodes** linked together.
```
Graph (Agent)
├─ Input Node → Input Block
├─ Process Node → LLM / Custom Block
├─ Decision Node → SmartDecisionMakerBlock
└─ Output Node → Output Block
```
### Blocks
Blocks are reusable components.
| Type | Purpose |
|------|---------|
| INPUT | Entry point for data |
| OUTPUT | Return values |
| AI | Call LLMs, generate text |
| WEBHOOK | Receive external events |
| STANDARD | General operations |
| AGENT | Execute nested agents |

## Building agents with the visual builder
1. Open <http://localhost:3000>.
2. Drag blocks from the **BlocksControl** panel onto the canvas.
3. Connect block handles to define data flow.
4. Configure each block’s parameters.
5. Click **Run** in the Primary Action Bar.

### Common block types
- `AITextGeneratorBlock` – Generate text from an LLM.
- `AIConversationBlock` – Multi‑turn chat.
- `SmartDecisionMakerBlock` – Conditional branching.
- Integration blocks: GitHub, Google, Discord, Notion, HTTP request.
- Control blocks: Loop, Branch, Delay.

## Agent execution triggers
### Manual HTTP execution
```http
POST /api/v1/graphs/{graph_id}/execute
Content-Type: application/json

{
  "inputs": { "input_name": "value" }
}
```
### Webhook trigger
```http
POST /api/v1/webhooks/{webhook_id}
Content-Type: application/json

{ "data": "payload" }
```
### Scheduled execution (cron syntax)
```json
{
  "schedule": "0 */2 * * *",
  "graph_id": "graph-uuid",
  "inputs": {}
}
```

## Monitoring execution
### WebSocket updates (JavaScript)
```javascript
const ws = new WebSocket('ws://localhost:8001/ws');
ws.onmessage = (e) => {
  const upd = JSON.parse(e.data);
  console.log(`Node ${upd.node_id}: ${upd.status}`);
};
```
### REST polling
```http
GET /api/v1/executions/{execution_id}
```

## Custom development with Forge (code‑first)
```bash
# Set up Forge environment (run from the classic folder)
cd classic
./run setup

# Create a new agent from a template
./run forge create my-agent

# Start the agent server
./run forge start my-agent
```
### Agent file layout
```
my-agent/
├─ agent.py            # Main logic
├─ abilities/         # Custom abilities
│  ├─ __init__.py
│  └─ custom.py
├─ prompts/            # Prompt templates
└─ config.yaml         # Configuration
```
### Example custom ability (Python)
```python
from forge import Ability, ability

@ability(
    name="custom_search",
    description="Search for information",
    parameters={"query": {"type": "string", "description": "Search query"}}
)
def custom_search(query: str) -> str:
    """Perform a web search and return results."""
    result = perform_search(query)  # Implement your search logic
    return result
```

## Benchmarking agents
```bash
# Run all benchmarks
./run benchmark

# Run a specific category (e.g., coding)
./run benchmark --category coding

# Benchmark a single agent
./run benchmark --agent my-agent
```
### Benchmark categories
- **Coding** – Code generation and debugging.
- **Retrieval** – Information search.
- **Web** – Browser interaction.
- **Writing** – Text generation.

### VCR cassettes for reproducibility
```bash
# Record new HTTP responses
./run benchmark --record

# Replay existing recordings
./run benchmark --playback
```

## Integrations and credentials
1. Open **Profile > Integrations** in the UI.
2. Select a provider (OpenAI, GitHub, Google, etc.).
3. Enter the API key or complete OAuth flow.
4. Credentials are encrypted and stored securely.

### Using credentials in a block (Python example)
```python
class MyLLMBlock(Block):
    def execute(self, inputs):
        creds = self.get_credentials("openai")
        client = OpenAI(api_key=creds.api_key)
        # Use client for LLM calls
```

Supported providers:
| Provider | Auth type |
|----------|----------|
| OpenAI   | API key |
| Anthropic| API key |
| GitHub   | OAuth |
| Google   | OAuth |
| Discord  | Bot token |
| Notion   | OAuth |

## Production deployment (Docker Compose)
```yaml
# docker-compose.prod.yml
services:
  rest_server:
    image: autogpt/platform-backend
    environment:
      - DATABASE_URL=postgresql://...
      - REDIS_URL=redis://redis:6379
      - RABBITMQ_URL=amqp://rabbitmq:5672
    ports:
      - "8006:8006"

  executor:
    image: autogpt/platform-backend
    command: poetry run executor

  frontend:
    image: autogpt/platform-frontend
    ports:
      - "3000:3000"
```
### Required environment variables
| Variable | Description |
|----------|-------------|
| DATABASE_URL | PostgreSQL connection string |
| REDIS_URL | Redis connection string |
| RABBITMQ_URL | RabbitMQ connection string |
| ENCRYPTION_KEY | Key for encrypting stored credentials |
| SUPABASE_URL | Auth service URL |

### Generate an encryption key
```bash
cd autogpt_platform/backend
poetry run cli gen-encrypt-key
```

## Best practices
- Start with a simple graph of 3‑5 nodes.
- Test after each change; use the UI Run button or API call.
- Prefer webhooks for event‑driven agents.
- Monitor LLM usage via the credits panel.
- Version agents before major edits (export graph JSON).
- Run benchmarks regularly to detect regressions.

## Common troubleshooting
**Containers fail to start**
```bash
docker compose ps            # Check status
docker compose logs          # View logs
docker compose restart       # Restart services
```
**Database connection errors**
```bash
cd backend
poetry run prisma migrate deploy   # Apply migrations
```
**Execution hangs**
- Open RabbitMQ management UI at <http://localhost:15672> (guest/guest).
- Clear stuck jobs or restart the executor service.

## Checklist
- [ ] Clone repo and copy `.env.example` → `.env`.
- [ ] Build and start Docker services.
- [ ] Add required API keys in **Profile > Integrations**.
- [ ] Create a graph in the visual builder.
- [ ] Connect a trigger (manual, webhook, or schedule).
- [ ] Run the agent and verify output.
- [ ] Add custom abilities via Forge if needed.
- [ ] Benchmark the agent.
- [ ] Deploy with `docker-compose.prod.yml` for production.
- [ ] Monitor costs and performance continuously.

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`crewai`](../crewai/SKILL.md) — CrewAI skill guides you to design, configure, and run role‑based multi‑agent teams in Python. Use it for build…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
