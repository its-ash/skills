# RAG Engineering
Design and build Retrieval‑Augmented Generation (RAG) systems that turn large document collections into high‑quality context for large language models (LLMs). The skill covers chunking, embedding, vector store selection, retrieval strategies, hybrid search, reranking, evaluation, and operational maintenance.

## When to use
- You have unstructured text (articles, PDFs, code, logs) that must be searchable by an LLM.
- You need low‑latency, accurate retrieval for question answering, chat, or recommendation.
- You want to avoid hallucinations caused by irrelevant or missing context.
- You must scale to millions of vectors or handle frequent document updates.

## Core Principles
1. **Chunk quality drives retrieval quality** – Bad chunks produce bad results.
2. **Embedding consistency** – Use the same model for queries and documents unless you deliberately combine them.
3. **Separate retrieval evaluation** – Measure recall/precision of the retrieval step independently of LLM generation.
4. **Latency matters** – Optimize indexing, filtering, and batch operations to meet response‑time targets.

## Semantic Chunking
Chunk documents by meaning, not by token count.
- Detect sentence boundaries and headings.
- Split when semantic similarity between consecutive sentences drops below a threshold (e.g., cosine < 0.8).
- Overlap 10‑20 % of tokens between adjacent chunks to preserve context.
- Attach metadata: `source_id`, `section`, `page_number`, `tags`.

```python
from sentence_transformers import SentenceTransformer
import numpy as np

model = SentenceTransformer('all-MiniLM-L6-v2')

def semantic_chunks(text, max_len=512, overlap=64):
    sentences = text.split('.')  # simple split; replace with a proper tokenizer
    chunks = []
    i = 0
    while i < len(sentences):
        window = sentences[i:i+max_len]
        # compute embedding of window to check similarity with next sentence
        emb = model.encode(' '.join(window))
        if i + max_len < len(sentences):
            next_emb = model.encode(sentences[i+max_len])
            if np.dot(emb, next_emb) > 0.8:
                # extend window until similarity drops
                pass
        chunk_text = '.'.join(window)
        chunks.append(chunk_text.strip())
        i += max_len - overlap
    return chunks
```

## Hierarchical Retrieval
Index at multiple granularities to balance recall and precision.
- **Level 1**: Paragraph‑size chunks (≈200 words) for coarse retrieval.
- **Level 2**: Section‑size chunks (≈800 words) for fine‑grained context.
- **Level 3**: Whole‑document vectors for fallback.
Workflow:
1. Query → Level 1 → top‑k candidates.
2. Retrieve candidate IDs, fetch their parent sections (Level 2).
3. Re‑rank with an LLM or cross‑encoder.
4. Assemble final context from the highest‑resolution chunks.

## Hybrid Search
Combine dense vector similarity with sparse keyword matching.
- **Dense**: Vector similarity (cosine) captures semantics.
- **Sparse**: BM25 or SPLADE captures exact term matches.
- **Fusion**: Use Reciprocal Rank Fusion (RRF) or weighted sum.

```python
# Example RRF fusion
dense_scores = {doc_id: 1/(rank+1) for rank, doc_id in enumerate(dense_ids)}
keyword_scores = {doc_id: 1/(rank+1) for rank, doc_id in enumerate(keyword_ids)}
combined = {}
for doc_id in set(dense_scores) | set(keyword_scores):
    combined[doc_id] = dense_scores.get(doc_id,0) * 0.6 + keyword_scores.get(doc_id,0) * 0.4
ranked = sorted(combined.items(), key=lambda x: -x[1])[:k]
```

## Retrieval Pipeline
1. **Pre‑process** – Clean HTML, remove boilerplate, apply semantic chunking.
2. **Embed** – Encode each chunk with a sentence‑transformer or OpenAI embedding model.
3. **Store** – Upsert vectors and payload into a vector database (e.g., Qdrant).
4. **Search** – Perform hybrid search with optional filters (metadata, date range).
5. **Rerank** – Use a cross‑encoder or LLM to reorder top‑k results.
6. **Assemble** – Concatenate selected chunks, respecting the LLM context window.
7. **Prompt** – Insert assembled context into the prompt template.

## Reranking with LLM
```python
from openai import OpenAI
client = OpenAI()

def rerank(query, candidates, top_n=5):
    # Build a single prompt that asks the model to rank candidates
    prompt = f"Query: {query}\n\nCandidates:\n"
    for i, doc in enumerate(candidates, 1):
        prompt += f"{i}. {doc['text']}\n"
    prompt += "\nReturn the numbers of the most relevant candidates in order, separated by commas."
    response = client.chat.completions.create(model='gpt-4o-mini', messages=[{'role':'user','content':prompt}])
    order = [int(x) for x in response.choices[0].message.content.split(',')][:top_n]
    return [candidates[i-1] for i in order]
```

## Vector Store Selection – Qdrant Example
Qdrant provides fast, filtered, and scalable vector search.

```bash
pip install qdrant-client
```

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct, Filter, FieldCondition, MatchValue

client = QdrantClient(host='localhost', port=6333)

# Create collection for dense embeddings
client.create_collection(
    collection_name='rag_docs',
    vectors_config=VectorParams(size=384, distance=Distance.COSINE),
    on_disk_payload=True
)

# Batch upsert chunks
points = [
    PointStruct(id=chunk_id, vector=embed.tolist(), payload={
        'source': src_id,
        'section': sec_id,
        'tags': tags
    })
    for chunk_id, embed, src_id, sec_id, tags in prepared_chunks
]
client.upsert(collection_name='rag_docs', points=points, wait=True)
```
### Filtered Search
```python
filter_expr = Filter(must=[
    FieldCondition(key='tags', match=MatchValue(value='finance')),
    FieldCondition(key='source', match=MatchValue(value='annual_report'))
])
results = client.search(
    collection_name='rag_docs',
    query_vector=query_emb.tolist(),
    query_filter=filter_expr,
    limit=10,
    with_payload=True
)
```
### Multi‑Vector (Hybrid) Support
```python
client.create_collection(
    collection_name='hybrid',
    vectors_config={
        'dense': VectorParams(size=384, distance=Distance.COSINE),
        'sparse': VectorParams(size=30000, distance=Distance.DOT)
    }
)
# Insert named vectors
client.upsert(
    collection_name='hybrid',
    points=[
        PointStruct(
            id=1,
            vector={'dense': dense_vec, 'sparse': sparse_vec},
            payload={'text': '...'}
        )
    ]
)
# Search dense part only
dense_results = client.search(
    collection_name='hybrid',
    query_vector=('dense', query_dense),
    limit=5
)
```
### Performance Tuning
- Increase `ef_construct` and `m` for higher recall at indexing cost.
- Use `on_disk_payload=True` for large metadata.
- Enable scalar quantization (`INT8`) for collections > 1 M vectors.
- Batch upserts (`wait=False`) and batch searches (`search_batch`).

## Anti‑Patterns
- **Fixed‑size chunks** – Break sentences and lose context.
- **Embedding everything with one model** – Different content types (code vs. prose) may need specialized models.
- **No overlap** – Context discontinuities cause poor retrieval.
- **Single retrieval strategy** – All queries are not the same; some need keyword focus, others semantic.
- **Skipping reranking** – Top‑k dense results often contain irrelevant items.
- **Never refreshing embeddings** – Stale vectors lead to missed information.

## Sharp Edges (Common Failure Modes)
| Issue | Severity | Remedy |
|---|---|---|
| Fixed‑size chunking cuts sentences | High | Use semantic chunking with overlap |
| Pure semantic search without metadata filter | Medium | Add keyword filter or hybrid fusion |
| Same embedding model for heterogeneous data | Medium | Evaluate per‑type models; store multiple vectors |
| Directly using first‑stage results | Medium | Add LLM‑based reranking |
| Prompt exceeds LLM context window | Medium | Apply relevance threshold; drop low‑score chunks |
| Retrieval quality not measured | High | Compute recall@k on a held‑out query set |
| Embeddings not refreshed after document change | Medium | Schedule incremental re‑indexing |
| One retrieval config for all query types | Medium | Detect query intent; switch between BM25‑only, dense‑only, or hybrid |

## Best Practices
1. **Batch operations** – Upsert and search in batches of ≥ 1 000 points.
2. **Payload indexing** – Create indexes on fields used for filtering (`category`, `timestamp`).
3. **Quantization** – Enable for collections > 1 M vectors to reduce RAM.
4. **Sharding** – Deploy sharded clusters when collection size exceeds 10 M vectors.
5. **Connection pooling** – Reuse a single `QdrantClient` per process.
6. **Evaluation pipeline** – Maintain a test set of queries with ground‑truth documents; compute recall@k and MRR after each indexing change.
7. **Monitoring** – Track latency, error rates, and index size; alert on spikes.
8. **Security** – Restrict vector store access with API keys; encrypt payloads if they contain PII.

## Checklist
- [ ] Clean raw documents and remove boilerplate.
- [ ] Apply semantic chunking with overlap and metadata.
- [ ] Encode chunks with a consistent embedding model.
- [ ] Choose a vector store (Qdrant, Chroma, FAISS) that meets latency and scaling needs.
- [ ] Create collection with appropriate distance metric (COSINE for normalized embeddings).
- [ ] Index payload fields used for filters.
- [ ] Upsert vectors in batches; enable `on_disk_payload` for large metadata.
- [ ] Implement hybrid search: dense + BM25 (or SPLADE).
- [ ] Add a reranking step (cross‑encoder or LLM).
- [ ] Assemble final context respecting the LLM’s context window.
- [ ] Evaluate retrieval recall@k on a validation set.
- [ ] Set up periodic embedding refresh for updated documents.
- [ ] Monitor latency, error rates, and storage usage.
- [ ] Secure vector store access with authentication and encryption.
