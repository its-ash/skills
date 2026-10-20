---
name: langchain-langgraph
description: "Build LLM applications with LangChain agents, chains, RAG, memory, vector stores and stateful multi-actor workflows with LangGraph StateGraph, reducers, checkpointers, human-in-the-loop. Use when creating chatbots, tool-using agents, RAG pipelines, production agent workflows, LangChain, LangGraph, ChatOpenAI, ChatAnthropic, LCEL, Runnable, retriever, embeddings, Chroma, FAISS, Pinecone, document loaders, splitters, LangSmith, LangServe, graph nodes, edges, conditional edges, state reducers, checkpointers, interrupts."
---

# LangChain and LangGraph

LangChain builds LLM applications with composable models, chains, agents, memory, and RAG. LangGraph builds stateful, multi-actor agent workflows as explicit graphs with persistence and human-in-the-loop control.

## When to use

Use LangChain when:
- You need agents with tool calling and ReAct reasoning.
- You implement RAG pipelines.
- You want to swap LLM providers.
- You build chatbots with conversation memory.
- You prototype or deploy with LangSmith observability.

Use LangGraph when:
- You need stateful workflows with cycles or branches.
- You need fine-grained control over agent flow.
- You build multi-agent systems.
- You need persistence, resumption, or human approval.
- You run production agents with complex logic.

Use alternatives for specialized needs: LlamaIndex for document Q&A, Haystack for search pipelines, Semantic Kernel for Microsoft ecosystems.

## Installation

```bash
pip install -U langchain langgraph
pip install langchain-openai langchain-anthropic langchain-google-genai
pip install langchain-community langchain-chroma
```

LangChain requires Python 3.10+. LangGraph requires Python 3.9+. Use Python 3.10+ when using both.

## LangChain

### Models

```python
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic

llm = ChatOpenAI(model='gpt-4o')
llm = ChatAnthropic(model='claude-sonnet-4-5-20250929')

for chunk in llm.stream('Write a short poem'):
    print(chunk.content, end='', flush=True)
```

### Agents

Simple ReAct-style agent:

```python
from langchain.agents import create_agent
from langchain_anthropic import ChatAnthropic

def get_weather(city: str) -> str:
    """Get current weather for a city."""
    return f"It's sunny in {city}, 72°F"

agent = create_agent(
    model=ChatAnthropic(model='claude-sonnet-4-5-20250929'),
    tools=[get_weather],
    system_prompt='You are a helpful assistant. Use tools when needed.'
)

result = agent.invoke({'messages': [{'role': 'user', 'content': "What's the weather in Paris?"}]})
print(result['messages'][-1].content)
```

Tool-calling agent with verbose execution:

```python
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain.tools import Tool

calculator = Tool(
    name='Calculator',
    func=lambda x: str(eval(x)),
    description='Evaluate a valid Python math expression.'
)

agent = create_tool_calling_agent(llm=llm, tools=[calculator], prompt='Answer questions using tools.')
executor = AgentExecutor(agent=agent, tools=[calculator], verbose=True)
result = executor.invoke({'input': 'What is 25 * 17 + 142?'})
```

Structured output:

```python
from langchain_core.pydantic_v1 import BaseModel, Field

class WeatherReport(BaseModel):
    city: str = Field(description='City name')
    temperature: float = Field(description='Temperature in Fahrenheit')
    condition: str = Field(description='Weather condition')

structured_llm = llm.with_structured_output(WeatherReport)
result = structured_llm.invoke('It is 65F and sunny in San Francisco')
```

Custom tool with error handling:

```python
from langchain.tools import tool

@tool
def risky_operation(query: str) -> str:
    """Perform an operation that might fail."""
    try:
        return f'Success: {query}'
    except Exception as e:
        return f'Error: {str(e)}'
```

Notes:
- Independent tool calls can run in parallel.
- Stream agent steps with executor.stream when available.
- Handle tool errors inside tools or in the executor.

### Memory

```python
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationChain

memory = ConversationBufferMemory()
conversation = ConversationChain(llm=llm, memory=memory, verbose=True)

conversation.predict(input="Hi, I'm Alice")
conversation.predict(input="What's my name?")
```

### RAG

Basic pipeline:

```python
from langchain_community.document_loaders import WebBaseLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_openai import OpenAIEmbeddings
from langchain_chroma import Chroma
from langchain.chains import RetrievalQA

loader = WebBaseLoader('https://docs.python.org/3/tutorial/')
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
splits = splitter.split_documents(docs)

vectorstore = Chroma.from_documents(documents=splits, embedding=OpenAIEmbeddings())
retriever = vectorstore.as_retriever(search_kwargs={'k': 4})

qa_chain = RetrievalQA.from_chain_type(
    llm=llm, retriever=retriever, return_source_documents=True
)
result = qa_chain({'query': 'What are Python decorators?'})
```

Conversational RAG:

```python
from langchain.chains import ConversationalRetrievalChain

qa = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=retriever,
    memory=ConversationBufferMemory(memory_key='chat_history', return_messages=True)
)
qa({'question': 'What is Python used for?'})
qa({'question': 'Can you elaborate on web development?'})
```

### Vector stores

```python
# Chroma (local)
from langchain_chroma import Chroma
vectorstore = Chroma.from_documents(documents=docs, embedding=OpenAIEmbeddings(), persist_directory='./chroma_db')

# Pinecone (cloud)
from langchain_pinecone import PineconeVectorStore
vectorstore = PineconeVectorStore.from_documents(documents=docs, embedding=OpenAIEmbeddings(), index_name='my-index')

# FAISS (local similarity search)
from langchain_community.vectorstores import FAISS
vectorstore = FAISS.from_documents(docs, OpenAIEmbeddings())
vectorstore.save_local('faiss_index')
vectorstore = FAISS.load_local('faiss_index', OpenAIEmbeddings())
```

### Document loaders and splitters

Loaders:
- WebBaseLoader for web pages.
- PyPDFLoader for PDFs.
- GithubFileLoader for repository files.
- CSVLoader for CSV files.

Splitters:
- RecursiveCharacterTextSplitter for general text. Use chunk sizes around 500-1000 characters with overlap.
- PythonCodeTextSplitter for Python code.
- SemanticChunker for meaning-based chunks.

### Observability

```python
import os
os.environ['LANGCHAIN_TRACING_V2'] = 'true'
os.environ['LANGCHAIN_API_KEY'] = 'your-api-key'
os.environ['LANGCHAIN_PROJECT'] = 'my-project'
```

All chains and agents are traced automatically. View traces in LangSmith.

### LangChain best practices
- Start with create_agent for most cases.
- Enable streaming for long responses.
- Add error handling because tools can fail.
- Use LangSmith for debugging.
- Optimize chunk size for RAG.
- Version prompts in production.
- Cache embeddings when possible.
- Monitor token usage and cost.

## LangGraph

### Basic agent graph

```python
from typing import Annotated, TypedDict
from langgraph.graph import StateGraph, START, END
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

class AgentState(TypedDict):
    messages: Annotated[list, add_messages]

@tool
def search(query: str) -> str:
    """Search the web for information."""
    return f'Results for: {query}'

@tool
def calculator(expression: str) -> str:
    """Evaluate a math expression."""
    return str(eval(expression))

tools = [search, calculator]
llm = ChatOpenAI(model='gpt-4o').bind_tools(tools)

def agent(state: AgentState) -> dict:
    response = llm.invoke(state['messages'])
    return {'messages': [response]}

tool_node = ToolNode(tools)

def should_continue(state: AgentState) -> str:
    last_message = state['messages'][-1]
    if last_message.tool_calls:
        return 'tools'
    return END

graph = StateGraph(AgentState)
graph.add_node('agent', agent)
graph.add_node('tools', tool_node)
graph.add_edge(START, 'agent')
graph.add_conditional_edges('agent', should_continue, ['tools', END])
graph.add_edge('tools', 'agent')

app = graph.compile()
result = app.invoke({'messages': [('user', 'What is 25 * 4?')]})
```

### State and reducers

Use reducers to control how updates merge into state.

```python
from typing import Annotated, TypedDict
from operator import add

def merge_dicts(left: dict, right: dict) -> dict:
    return {**left, **right}

class ResearchState(TypedDict):
    messages: Annotated[list, add_messages]
    findings: Annotated[dict, merge_dicts]
    sources: Annotated[list[str], add]
    current_step: str
    errors: Annotated[int, lambda a, b: a + b]
```

Rules:
- Fields without reducers overwrite on update.
- Fields with reducers accumulate or merge.
- Nodes should return only the fields they update.
- Keep state focused; avoid giant monolithic state.

### Conditional branching

```python
from langgraph.graph import StateGraph, START, END

class RouterState(TypedDict):
    query: str
    query_type: str
    result: str

def classifier(state: RouterState) -> dict:
    query = state['query'].lower()
    if 'code' in query:
        return {'query_type': 'coding'}
    if 'search' in query:
        return {'query_type': 'search'}
    return {'query_type': 'chat'}

def route_query(state: RouterState) -> str:
    return state['query_type']

graph = StateGraph(RouterState)
graph.add_node('classifier', classifier)
graph.add_node('coding', lambda s: {'result': 'code'})
graph.add_node('search', lambda s: {'result': 'search'})
graph.add_node('chat', lambda s: {'result': 'chat'})

graph.add_edge(START, 'classifier')
graph.add_conditional_edges(
    'classifier',
    route_query,
    {'coding': 'coding', 'search': 'search', 'chat': 'chat'}
)
graph.add_edge('coding', END)
graph.add_edge('search', END)
graph.add_edge('chat', END)

app = graph.compile()
```

### Persistence and threads

Use a checkpointer to save state between invocations.

```python
from langgraph.checkpoint.memory import MemorySaver

checkpointer = MemorySaver()
app = graph.compile(checkpointer=checkpointer)

config = {'configurable': {'thread_id': 'user-123'}}
app.invoke({'messages': [('user', 'Hello')]}, config=config)
app.invoke({'messages': [('user', 'What did I say?')]}, config=config)
```

For production, use a durable checkpointer such as SQLite or Postgres instead of in-memory storage.

### Human-in-the-loop

Compile with interrupts to pause before sensitive nodes, then resume with the same thread ID.

```python
app = graph.compile(checkpointer=checkpointer, interrupt_before=['tools'])
```

Review or modify state, then invoke again with the same thread_id to continue.

### LangGraph best practices
- Always define explicit exit conditions.
- Add a maximum iteration counter for cyclic graphs.
- Use state for all data flow.
- Use reducers for accumulation.
- Keep state small and well-scoped.
- Use checkpointers for resumable or multi-turn agents.
- Test routing functions independently.

### LangGraph anti-patterns
- Infinite loops without exit conditions.
- Stateless nodes that ignore graph state.
- Giant monolithic state objects.
- Unbounded cycles without iteration limits.

### LangGraph limitations
- Python-first; TypeScript support is early.
- Graph concepts add a learning curve.
- State management can become complex.
- Debugging requires tracing and careful state inspection.

## Choosing between LangChain and LangGraph

| Feature | LangChain | LangGraph |
| --- | --- | --- |
| Best for | Quick agents, RAG | Complex workflows |
| Abstraction level | High | Low |
| Startup code | Under 10 lines | About 30 lines |
| Control | Simple | Full control |
| Stateful workflows | Limited | Native |
| Cyclic graphs | No | Yes |
| Human-in-the-loop | Basic | Advanced |

Use LangChain for fast agent and RAG development. Use LangGraph when you need explicit state, cycles, persistence, or multi-agent coordination.

## Checklist

- [ ] Choose LangChain for simple agents/RAG; LangGraph for stateful workflows.
- [ ] Install only needed provider and vector store packages.
- [ ] Define typed state for LangGraph workflows.
- [ ] Add reducers for accumulated fields.
- [ ] Add exit conditions and iteration limits to cycles.
- [ ] Handle tool errors.
- [ ] Use LangSmith or checkpointers for debugging and resumption.
- [ ] Test retrieval, routing, and tool paths separately.

## Related skills

Load these when the task spans more than this skill.

- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`llamaindex`](../llamaindex/SKILL.md) — LlamaIndex skill for building RAG applications with document ingestion, indexing, and querying. Use when creat…
- [`crewai`](../crewai/SKILL.md) — CrewAI skill guides you to design, configure, and run role‑based multi‑agent teams in Python. Use it for build…
- [`autogpt`](../autogpt/SKILL.md) — AutoGPT is a platform for building, deploying, and managing continuous autonomous AI agents using a visual wor…
- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`llm-advanced-techniques`](../llm-advanced-techniques/SKILL.md) — Advanced LLM Techniques for compressing models with knowledge distillation, extending transformer context wind…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
