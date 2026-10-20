---
name: crewai
description: "CrewAI lets you build role-based multi-agent teams in Python by defining agents with specialized roles, tasks with dependencies, and process types like sequential or hierarchical execution. Use when you need to create agent crews, configure agents.yaml and tasks.yaml, add built-in tools via crewai[tools], write custom tools, enable memory or event-driven flows, orchestrate autonomous agents, set up hierarchical processes, or integrate with LLMs for collaborative problem solving."
---

# CrewAI – Role‑Based Multi‑Agent Orchestration

Create teams of autonomous agents that collaborate to solve complex tasks. Define clear roles, goals, and backstories for each agent, connect tasks with context, and choose a process model that fits the workflow.

## When to use CrewAI
- You need a team of agents with distinct specialties (researcher, writer, analyst, etc.).
- Tasks must be executed in a defined order or hierarchy.
- You want built‑in memory to retain context across tasks.
- You prefer a lightweight framework without LangChain dependencies.
- You need to integrate external tools (web search, file I/O, custom APIs).

---

## Installation
```bash
pip install crewai                # Core framework
pip install 'crewai[tools]'      # Optional: 50+ built‑in tools
```

## Core Concepts
### Agent
```python
from crewai import Agent, LLM

agent = Agent(
    role="Data Scientist",
    goal="Extract insights from sales data",
    backstory="PhD in statistics with industry experience.",
    llm=LLM(model="gpt-4o"),   # optional, defaults to OpenAI gpt‑4o
    tools=[],                  # list of tool instances
    memory=True,               # enable short‑term memory
    verbose=True,
    max_iter=15,               # stop after 15 reasoning cycles
    max_rpm=10                 # rate limit for API calls
)
```
**Key fields**
- **role**: job title or persona.
- **goal**: what the agent must achieve.
- **backstory**: context that shapes responses.
- **tools**: instances of `BaseTool` subclasses.
- **memory**: `True` enables short‑term memory; long‑term can be configured on the crew.
- **max_iter**: prevents infinite loops.
- **max_rpm**: respects provider rate limits.

### Task
```python
from crewai import Task

task = Task(
    description="Analyze Q4 2024 sales data and list top three trends.",
    expected_output="A markdown report with three bullet points and a brief summary.",
    agent=agent,
    context=[previous_task],   # optional, pass output of other tasks
    output_file="report.md",
    async_execution=False,
    human_input=False
)
```
**Important**: Always provide `expected_output` so the agent knows when it is done.

### Crew
```python
from crewai import Crew, Process

crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, write_task],
    process=Process.sequential,   # or Process.hierarchical
    memory=True,                  # crew‑level long‑term memory
    cache=True,                   # cache tool results
    max_rpm=10,
    verbose=True
)

result = crew.kickoff(inputs={"topic": "AI agents"})
print(result.raw)               # final output
print(result.tasks_output)      # dict of each task's output
print(result.token_usage)       # token consumption report
```
---

## Process Types
| Type | Behaviour |
|------|-----------|
| **Sequential** (default) | Tasks run one after another. Output of a task can be passed to the next via `context`.
| **Hierarchical** | A manager agent coordinates delegation. Use when tasks require dynamic assignment or when you want a planning layer.
| **Parallel** (experimental) | All tasks start simultaneously. Use only when tasks are independent.

### Hierarchical example
```python
from crewai import Crew, Process, Agent, Task

crew = Crew(
    agents=[researcher, analyst, writer],
    tasks=[research_task, analysis_task, write_task],
    process=Process.hierarchical,
    manager_llm=LLM(model="gpt-4o"),
    verbose=True
)
```
---

## Tool Integration
### Built‑in tools (install with `crewai[tools]`)
```python
from crewai_tools import (
    SerperDevTool,          # web search
    ScrapeWebsiteTool,      # HTML scraping
    FileReadTool,           # read local files
    PDFSearchTool,          # search PDFs
    YoutubeVideoSearchTool  # YouTube search
)

researcher = Agent(
    role="Researcher",
    goal="Find accurate information",
    tools=[SerperDevTool(), ScrapeWebsiteTool()],
    verbose=True
)
```
### Custom tool example
```python
from crewai.tools import BaseTool
from pydantic import Field

class CalculatorTool(BaseTool):
    name: str = "Calculator"
    description: str = "Performs arithmetic expressions. Input: expression string"

    def _run(self, expression: str) -> str:
        try:
            result = eval(expression)
            return f"Result: {result}"
        except Exception as e:
            return f"Error: {e}"

agent = Agent(
    role="Analyst",
    goal="Perform calculations",
    tools=[CalculatorTool()],
    verbose=True
)
```
---

## YAML Configuration (recommended for larger projects)
```
my_project/
├─ config/
│  ├─ agents.yaml
│  └─ tasks.yaml
├─ crew.py
└─ main.py
```
### agents.yaml
```yaml
researcher:
  role: "Senior Research Analyst"
  goal: "Find comprehensive information on {topic}"
  backstory: |
    You are an expert researcher with a track record of uncovering
    the latest developments in technology.
  tools:
    - SerperDevTool
    - WebsiteSearchTool
  verbose: true

writer:
  role: "Technical Writer"
  goal: "Create a clear, engaging article"
  backstory: |
    You translate complex ideas into concise prose for a broad audience.
  verbose: true
```
### tasks.yaml
```yaml
research_task:
  description: |
    Research {topic}. Include:
    1. Key facts
    2. Recent developments
    3. Expert opinions
  agent: researcher
  expected_output: |
    A markdown report with an executive summary, bullet‑point findings,
    and cited sources.

write_task:
  description: |
    Write a 800‑word article based on the research output.
    Use headings, an engaging intro, and a clear conclusion.
  agent: writer
  expected_output: "A polished markdown article ready for publication"
  context:
    - research_task
```
### crew.py
```python
from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, task, crew
from crewai_tools import SerperDevTool

@CrewBase
class ContentCrew:
    agents_config = "config/agents.yaml"
    tasks_config = "config/tasks.yaml"

    @agent
    def researcher(self) -> Agent:
        cfg = self.agents_config["researcher"]
        return Agent(
            role=cfg["role"],
            goal=cfg["goal"],
            backstory=cfg["backstory"],
            tools=[SerperDevTool()],
            verbose=cfg.get("verbose", False),
        )

    @agent
    def writer(self) -> Agent:
        cfg = self.agents_config["writer"]
        return Agent(
            role=cfg["role"],
            goal=cfg["goal"],
            backstory=cfg["backstory"],
            verbose=cfg.get("verbose", False),
        )

    @task
    def research_task(self) -> Task:
        return Task(config=self.tasks_config["research_task"])

    @task
    def write_task(self) -> Task:
        return Task(config=self.tasks_config["write_task"])

    @crew
    def crew(self) -> Crew:
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True,
        )
```
### main.py
```python
from my_project.crew import ContentCrew

if __name__ == "__main__":
    inputs = {"topic": "AI agents"}
    ContentCrew().crew().kickoff(inputs=inputs)
```
---

## Memory System
```python
crew = Crew(
    agents=[researcher],
    tasks=[research_task],
    memory=True,                     # enables short‑term memory
    embedder={
        "provider": "openai",
        "config": {"model": "text-embedding-3-small"}
    }
)
```
**Memory types**
- **Short‑term**: stored in ChromaDB, cleared after crew run.
- **Long‑term**: persisted in SQLite (configure `storage_dir`).
- **Entity**: vector store for named entities across runs.
Set `CREWAI_STORAGE_DIR` environment variable to change the storage location.
---

## LLM Providers
```python
from crewai import LLM

openai_llm = LLM(model="gpt-4o")                     # default
anthropic = LLM(model="claude-sonnet-4-5-20250929")
local = LLM(model="ollama/llama3.1", base_url="http://localhost:11434")
azure = LLM(model="azure/gpt-4o", base_url="https://my-azure-endpoint")
```
Pass the `llm` object to an `Agent` if you need a non‑default model.
---

## Flows – Event‑Driven Orchestration (advanced)
```python
from crewai.flow.flow import Flow, start, listen, router
from pydantic import BaseModel

class State(BaseModel):
    confidence: float = 0.0

class ReportFlow(Flow[State]):
    @start()
    def gather(self):
        return {"data": "collected"}

    @listen(gather)
    def analyze(self, data):
        self.state.confidence = 0.85
        return analysis_crew.kickoff(inputs=data)

    @router(analyze)
    def decide(self):
        return "high" if self.state.confidence > 0.8 else "low"

    @listen("high")
    def generate(self):
        return report_crew.kickoff()

flow = ReportFlow()
result = flow.kickoff()
```
Use flows when you need conditional branches, loops, or stateful coordination beyond simple sequential/hierarchical crews.
---

## Best Practices
- **Define narrow roles**: each agent should have a single area of expertise.
- **Specify `expected_output`** for every task.
- **Limit tools per agent**: 3‑5 tools keep prompts concise.
- **Enable memory** for tasks that depend on prior context.
- **Set `max_iter`** to avoid endless reasoning loops.
- **Use YAML** for readability in larger projects.
- **Cache tool results** when the same external call may be reused.
- **Rate‑limit** (`max_rpm`) to stay within provider quotas.
---

## Anti‑Patterns
| Issue | Why it hurts | Fix |
|-------|--------------|-----|
| Vague agent role | Agent lacks direction, leads to overlapping work. | Use specific titles like "Senior React Developer" or "Crypto Financial Analyst" and mention key skills in backstory. |
| Missing `expected_output` | Agent does not know when it is done; downstream tasks break. | Always include a clear, structured output description (e.g., JSON schema or markdown template). |
| Too many agents | Coordination overhead, slower execution. | Keep the crew to 3‑5 agents; let a single agent handle related subtasks or use tools instead. |
---

## Common Issues & Fixes
- **Agent stuck in a loop**: Reduce `max_iter` and/or lower `max_rpm`.
- **Task does not receive prior output**: Add the previous task to the `context` list of the dependent task.
- **Memory errors**: Set `CREWAI_STORAGE_DIR` to a writable directory or ensure SQLite dependencies are installed.
- **Tool not found**: Verify the tool class is imported and instantiated; install `crewai[tools]` if using built‑in tools.
---

## Checklist
- [ ] Python 3.10+ installed.
- [ ] `pip install crewai` (and `crewai[tools]` if needed).
- [ ] Define each agent with `role`, `goal`, `backstory`, and optional `tools`.
- [ ] Write a `Task` for every piece of work; include `expected_output` and `context` where required.
- [ ] Choose a `process` (`sequential` or `hierarchical`).
- [ ] Enable `memory` if tasks need to share context.
- [ ] Set `max_iter` and `max_rpm` to safe limits.
- [ ] Store configuration in YAML for maintainability (optional).
- [ ] Run `crew.kickoff(inputs={...})` and inspect `result.raw` and `result.tasks_output`.
- [ ] Review token usage and adjust LLM model or prompt size if needed.

## Related skills

Load these when the task spans more than this skill.

- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`autogpt`](../autogpt/SKILL.md) — AutoGPT is a platform for building, deploying, and managing continuous autonomous AI agents using a visual wor…
