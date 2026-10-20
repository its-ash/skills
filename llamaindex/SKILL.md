---
name: llamaindex
description: "LlamaIndex builds retrieval-augmented generation applications that ingest, index, and query private documents through vector stores and LLM-powered query engines. Use when creating document Q&A systems, chatbots with proprietary data, knowledge bases, or structured extraction pipelines; loading PDFs, Markdown, HTML, or Notion pages; configuring SentenceTransformers, OpenAI, or Cohere embeddings; persisting indexes to Chroma, Pinecone, Weaviate, or FAISS; composing query engines, retrievers, rerankers, and response synthesizers; building function-calling agents with tools; streaming chat engines with conversation memory; or enforcing Pydantic schemas on LLM outputs via custom prompt templates."
---

# LlamaIndex - Data Framework for LLM Applications

Build retrieval-augmented generation (RAG) applications with document ingestion, vector indexing, and query engines. Use for document Q&A, chatbots with private data, knowledge bases, and structured data extraction.

## When to use

- Building RAG applications over private documents
- Need document question-answering with citations
- Ingesting data from multiple sources (PDF, web, GitHub, databases, APIs)
- Creating knowledge bases for LLM queries
- Building conversational chatbots with memory
- Need structured output from document queries
- Evaluating response relevance and faithfulness

## Installation

```bash
# Starter package (recommended)
pip install llama-index

# Minimal core + specific integrations
pip install llama-index-core
pip install llama-index-llms-openai
pip install llama-index-embeddings-openai
```

## Core workflow

### 1. Load documents

```python
from llama_index.core import SimpleDirectoryReader, Document
from llama_index.readers.web import SimpleWebPageReader
from llama_index.readers.github import GithubRepositoryReader

# Directory of files
 documents = SimpleDirectoryReader("./data", recursive=True).load_data()

# Web pages
reader = SimpleWebPageReader()
documents = reader.load_data(["https://example.com"])

# GitHub repository
reader = GithubRepositoryReader(owner="user", repo="repo")
documents = reader.load_data(branch="main")

# Manual document with metadata
doc = Document(
    text="Document content",
    metadata={"source": "manual", "date": "2025-01-01"}
)
```

### 2. Create and persist index

```python
from llama_index.core import VectorStoreIndex, StorageContext

# Vector index (semantic search)
index = VectorStoreIndex.from_documents(documents)

# Persist to disk
index.storage_context.persist(persist_dir="./storage")

# Load persisted index
storage_context = StorageContext.from_defaults(persist_dir="./storage")
index = load_index_from_storage(storage_context)
```

### 3. Query the index

```python
# Basic query
query_engine = index.as_query_engine()
response = query_engine.query("What is the main topic?")
print(response)

# Streaming response
query_engine = index.as_query_engine(streaming=True)
response = query_engine.query("Explain quantum computing")
for text in response.response_gen:
    print(text, end="", flush=True)

# Custom configuration
query_engine = index.as_query_engine(
    similarity_top_k=3,
    response_mode="compact",  # or "tree_summarize", "simple_summarize"
    verbose=True
)
```

### 4. Retrieve relevant chunks

```python
# Vector retriever
retriever = index.as_retriever(similarity_top_k=5)
nodes = retriever.retrieve("machine learning")

# With metadata filtering
from llama_index.core.vector_stores import MetadataFilters, ExactMatchFilter

filters = MetadataFilters(filters=[
    ExactMatchFilter(key="category", value="tutorial"),
    ExactMatchFilter(key="difficulty", value="beginner")
])
retriever = index.as_retriever(similarity_top_k=3, filters=filters)
```

## Agents with tools

### Basic function agent

```python
from llama_index.core.agent import FunctionAgent
from llama_index.llms.openai import OpenAI

def multiply(a: int, b: int) -> int:
    """Multiply two numbers."""
    return a * b

llm = OpenAI(model="gpt-4o")
agent = FunctionAgent.from_tools(tools=[multiply], llm=llm, verbose=True)
response = agent.chat("What is 25 * 17?")
```

### RAG agent (document search + tools)

```python
from llama_index.core.tools import QueryEngineTool

query_tool = QueryEngineTool.from_defaults(
    query_engine=index.as_query_engine(),
    name="python_docs",
    description="Answer questions about Python programming"
)

agent = FunctionAgent.from_tools(tools=[query_tool, multiply], llm=llm)
response = agent.chat("According to the docs, what is Python used for?")
```

## Advanced patterns

### Chat engine (conversational with memory)

```python
chat_engine = index.as_chat_engine(
    chat_mode="condense_plus_context",  # or "context", "react"
    verbose=True
)

response1 = chat_engine.chat("What is Python?")
response2 = chat_engine.chat("Can you give examples?")  # Remembers context
```

### Structured output with Pydantic

```python
from pydantic import BaseModel
from llama_index.core.output_parsers import PydanticOutputParser

class Summary(BaseModel):
    title: str
    main_points: list[str]
    conclusion: str

output_parser = PydanticOutputParser(output_cls=Summary)
query_engine = index.as_query_engine(output_parser=output_parser)
response = query_engine.query("Summarize the document")
print(response.title, response.main_points)
```

### Custom prompt template

```python
from llama_index.core import PromptTemplate

qa_prompt = PromptTemplate(
    "Context: {context_str}\n"
    "Question: {query_str}\n"
    "Answer based only on context. If unknown, say 'I don't know'.\n"
    "Answer: "
)
query_engine = index.as_query_engine(text_qa_template=qa_prompt)
```

## Vector store integrations

### Chroma (local)

```python
from llama_index.vector_stores.chroma import ChromaVectorStore
import chromadb

db = chromadb.PersistentClient(path="./chroma_db")
collection = db.get_or_create_collection("my_collection")
vector_store = ChromaVectorStore(chroma_collection=collection)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
index = VectorStoreIndex.from_documents(documents, storage_context=storage_context)
```

### Pinecone (cloud)

```python
from llama_index.vector_stores.pinecone import PineconeVectorStore
import pinecone

pinecone.init(api_key="your-key", environment="us-west1-gcp")
pinecone_index = pinecone.Index("my-index")
vector_store = PineconeVectorStore(pinecone_index=pinecone_index)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
index = VectorStoreIndex.from_documents(documents, storage_context=storage_context)
```

### FAISS (fast local)

```python
from llama_index.vector_stores.faiss import FaissVectorStore
import faiss

faiss_index = faiss.IndexFlatL2(1536)  # embedding dimension
vector_store = FaissVectorStore(faiss_index=faiss_index)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
index = VectorStoreIndex.from_documents(documents, storage_context=storage_context)
```

## Customization

### Custom LLM

```python
from llama_index.llms.anthropic import Anthropic
from llama_index.core import Settings

Settings.llm = Anthropic(model="claude-sonnet-4-5-20250929")
```

### Custom embeddings

```python
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.core import Settings

Settings.embed_model = HuggingFaceEmbedding(
    model_name="sentence-transformers/all-mpnet-base-v2"
)
```

## Multi-modal RAG

```python
from llama_index.core import SimpleDirectoryReader
from llama_index.multi_modal_llms.openai import OpenAIMultiModal

documents = SimpleDirectoryReader(
    "./data", required_exts=[".jpg", ".png", ".pdf"]
).load_data()

index = VectorStoreIndex.from_documents(documents)
multi_modal_llm = OpenAIMultiModal(model="gpt-4o")
query_engine = index.as_query_engine(llm=multi_modal_llm)
response = query_engine.query("What is in the diagram on page 3?")
```

## Evaluation

```python
from llama_index.core.evaluation import RelevancyEvaluator, FaithfulnessEvaluator

relevancy = RelevancyEvaluator()
result = relevancy.evaluate_response(query="What is Python?", response=response)
print(f"Relevancy: {result.passing}")

faithfulness = FaithfulnessEvaluator()
result = faithfulness.evaluate_response(query="What is Python?", response=response)
print(f"Faithfulness: {result.passing}")
```

## Data ingestion patterns

```python
# Multiple file types
documents = SimpleDirectoryReader(
    "./data", recursive=True, required_exts=[".pdf", ".docx", ".txt", ".md"]
).load_data()

# Web scraping
from llama_index.readers.web import BeautifulSoupWebReader
reader = BeautifulSoupWebReader()
documents = reader.load_data(urls=["https://docs.python.org/3/tutorial/"])

# Database
from llama_index.readers.database import DatabaseReader
reader = DatabaseReader(sql_database_uri="postgresql://user:pass@localhost/db")
documents = reader.load_data(query="SELECT * FROM articles")

# API endpoints
from llama_index.readers.json import JSONReader
reader = JSONReader()
documents = reader.load_data("https://api.example.com/data.json")
```

## Best practices

1. Use vector indices for most cases - best performance
2. Persist indices to disk - avoid re-indexing
3. Chunk documents at 512-1024 tokens - optimal retrieval
4. Add metadata to documents - enables filtering and tracking
5. Use streaming responses - better UX for long answers
6. Enable verbose during development - see retrieval process
7. Evaluate responses - check relevance and faithfulness
8. Use chat engine for conversations - built-in memory
9. Monitor embedding and LLM costs - track usage

## Common patterns

### Document Q&A system

```python
documents = SimpleDirectoryReader("docs").load_data()
index = VectorStoreIndex.from_documents(documents)
index.storage_context.persist(persist_dir="./storage")

query_engine = index.as_query_engine(
    similarity_top_k=3,
    response_mode="compact",
    verbose=True
)
response = query_engine.query("What is the main topic?")
print(response)
print(f"Sources: {[n.metadata['file_name'] for n in response.source_nodes]}")
```

### Chatbot with memory

```python
chat_engine = index.as_chat_engine(
    chat_mode="condense_plus_context",
    verbose=True
)

while True:
    user_input = input("You: ")
    if user_input.lower() == "quit":
        break
    response = chat_engine.chat(user_input)
    print(f"Bot: {response}")
```

## Performance reference

| Operation | Latency | Notes |
|-----------|---------|-------|
| Index 100 docs | ~10-30s | One-time, can persist |
| Query (vector) | ~0.5-2s | Retrieval + LLM |
| Streaming query | ~0.5s first token | Better UX |
| Agent with tools | ~3-8s | Multiple tool calls |

## LlamaIndex vs LangChain

| Feature | LlamaIndex | LangChain |
|---------|------------|-----------|
| Best for | RAG, document Q&A | Agents, general LLM apps |
| Data connectors | 300+ (LlamaHub) | 100+ |
| RAG focus | Core feature | One of many |
| Learning curve | Easier for RAG | Steeper |

**Choose LlamaIndex when:** primary use case is RAG, need many data connectors, want simpler API for document Q&A.

**Choose LangChain when:** building complex agents, need general-purpose tools, want more flexibility for multi-step workflows.

## Resources

- GitHub: https://github.com/run-llama/llama_index
- Docs: https://developers.llamaindex.ai/python/framework/
- LlamaHub: https://llamahub.ai (data connectors)
- License: MIT

## Related skills

Load these when the task spans more than this skill.

- [`langchain-langgraph`](../langchain-langgraph/SKILL.md) — Build LLM applications with LangChain (agents, chains, RAG, memory, vector stores) and stateful multi-actor wo…
- [`llm-app-patterns`](../llm-app-patterns/SKILL.md) — Production-ready patterns for building LLM applications. Covers RAG pipelines, agent architectures (ReAct, fun…
- [`llm-evaluation-observability`](../llm-evaluation-observability/SKILL.md) — Provides a complete workflow to benchmark LLMs with lm-evaluation-harness, accelerate runs with vLLM, track tr…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`fastapi`](../fastapi/SKILL.md) — FastAPI skill for building production‑ready async endpoints with FastAPI, Pydantic v2, SQLAlchemy 2.0, depende…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`dspy`](../dspy/SKILL.md) — Build complex AI systems with declarative programming using DSPy (Stanford NLP). Covers signatures, modules (P…
