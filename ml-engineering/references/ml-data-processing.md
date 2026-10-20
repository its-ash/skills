# ML Data Processing

Create high‑quality training data from raw web scrapes, logs, or media collections. The skill combines **NeMo Curator** (GPU‑accelerated curation) and **Ray Data** (distributed streaming) to filter, deduplicate, redact, and export multi‑modal datasets.

## When to use
- You have >100 GB of raw text, images, video, or audio that must be cleaned before model training.
- You need fast deduplication (exact, fuzzy, or semantic) on GPU clusters.
- You must remove PII, NSFW, or low‑quality content.
- You want a pipeline that scales from a single GPU to a multi‑node cluster.
- You plan to feed the data directly into PyTorch, TensorFlow, or Ray Train.

---

## Workflow Overview
1. **Ingest** – Read Parquet, JSONL, CSV, or image/video/audio folders.
2. **Quality filtering** – Apply heuristic filters, language filters, or classifier scores.
3. **Deduplication** – Choose exact, fuzzy (MinHash + LSH), or semantic (embedding‑based) dedup.
4. **Redaction** – Run PII and NSFW detectors.
5. **Multi‑modal enrichment** – Generate CLIP, InternVideo, or ASR embeddings if needed.
6. **Distributed execution** – Run the pipeline on a Ray cluster or a Dask‑CUDA GPU cluster.
7. **Export** – Write the curated data to Parquet (recommended) or CSV/JSON.

---

## Using NeMo Curator (GPU‑accelerated curation)
### Installation
```bash
# Text only, CUDA 12
uv pip install "nemo-curator[text_cuda12]"
# All modalities, CUDA 12
uv pip install "nemo-curator[all_cuda12]"
# CPU‑only (slow)
uv pip install "nemo-curator[cpu]"
```
### Load data
```python
import pandas as pd
from nemo_curator.datasets import DocumentDataset

df = pd.read_parquet("s3://raw-data/*.parquet")
dataset = DocumentDataset(df)
```
### Quality filtering (example heuristics)
```python
from nemo_curator.filters import (
    WordCountFilter,
    RepeatedLinesFilter,
    UrlRatioFilter,
    LanguageIdentificationFilter,
)

dataset = dataset.filter(WordCountFilter(min_words=100, max_words=50000))

dataset = dataset.filter(RepeatedLinesFilter(max_repeated_line_fraction=0.2))

dataset = dataset.filter(UrlRatioFilter(max_url_ratio=0.3))

dataset = dataset.filter(LanguageIdentificationFilter(target_languages=["en"]))
```
### Deduplication
#### Exact
```python
from nemo_curator.modules import ExactDuplicates

dataset = ExactDuplicates(id_field="id", text_field="text")(dataset)
```
#### Fuzzy (MinHash + LSH)
```python
from nemo_curator.modules import FuzzyDuplicates

fuzzy = FuzzyDuplicates(
    id_field="id",
    text_field="text",
    num_hashes=260,
    num_buckets=20,
    hash_method="md5",
)

dataset = fuzzy(dataset)
```
#### Semantic (embedding based)
```python
from nemo_curator.modules import SemanticDuplicates

semantic = SemanticDuplicates(
    id_field="id",
    text_field="text",
    embedding_model="sentence-transformers/all-MiniLM-L6-v2",
    threshold=0.8,
)

dataset = semantic(dataset)
```
### PII & NSFW redaction
```python
from nemo_curator.modifiers import PIIRedactor
from nemo_curator.modules import Modify

pii = PIIRedactor(
    supported_entities=["EMAIL_ADDRESS", "PHONE_NUMBER", "PERSON", "LOCATION"],
    anonymize_action="replace",
)

dataset = Modify(pii)(dataset)
```
*Replace `PIIRedactor` with `NSFWFilter` for image/video streams.*
### Multi‑modal enrichment (example image pipeline)
```python
from nemo_curator.image import AestheticFilter, NSFWFilter, CLIPEmbedder

images = AestheticFilter(threshold=5.0)(image_dataset)
images = NSFWFilter(threshold=0.9)(images)
embeds = CLIPEmbedder(model="openai/clip-vit-base-patch32")(images)
```
### Distributed GPU execution
```python
from nemo_curator import get_client
import dask_cuda

client = get_client(cluster_type="gpu", n_workers=8)  # 8‑GPU node
# All subsequent modules run on the cluster
```
### Save curated data
```python
# Parquet is the default and most efficient format
dataset.to_parquet("s3://curated-output/")
```
---

## Using Ray Data (scalable streaming transforms)
### Installation
```bash
pip install -U 'ray[data]'
```
### Load data (any supported format)
```python
import ray

ds = ray.data.read_parquet("s3://raw-data/*.parquet")   # text
# ds = ray.data.read_images("s3://images/")            # images
# ds = ray.data.read_json("gs://bucket/data.json")    # JSON
```
### Transformations
#### Vectorized batch map (recommended)
```python
def clean_batch(batch):
    # Example: lower‑case text and drop short rows
    batch["text"] = batch["text"].str.lower()
    keep = batch["text"].str.split().str.len() > 5
    return batch[keep]

ds = ds.map_batches(clean_batch, batch_size=10_000)
```
#### Row‑wise map (slower)
```python
ds = ds.map(lambda row: {**row, "len": len(row["text"].split())})
```
#### Filter rows
```python
 ds = ds.filter(lambda row: row["len"] > 5)
```
#### Group‑by aggregation
```python
agg = ds.groupby("category").count()
```
### GPU‑accelerated transforms (e.g., image preprocessing)
```python
def preprocess_images_gpu(batch):
    import torch
    imgs = torch.tensor(batch["image"]).cuda()
    processed = (imgs * 255).byte()
    return {"processed": processed.cpu().numpy()}

 ds = ds.map_batches(preprocess_images_gpu, batch_size=64, num_gpus=1)
```
### Write output
```python
# Parquet is preferred for downstream training
 ds.write_parquet("s3://curated-output/")
```
### Integration with Ray Train (distributed training)
```python
from ray.train import ScalingConfig
from ray.train.torch import TorchTrainer

train_ds = ray.data.read_parquet("s3://curated-output/train/*.parquet")

def train_func(config):
    train = ray.train.get_dataset_shard("train")
    for epoch in range(5):
        for batch in train.iter_batches(batch_size=32):
            # model training logic here
            pass

trainer = TorchTrainer(
    train_func,
    datasets={"train": train_ds},
    scaling_config=ScalingConfig(num_workers=4, use_gpu=True),
)
trainer.fit()
```
### Convert to framework tensors
```python
# PyTorch
torch_ds = ds.to_torch(label_column="label", batch_size=32)
# TensorFlow
tf_ds = ds.to_tf(feature_columns=["image"], label_column="label", batch_size=32)
```
---

## Common Patterns
### 1. End‑to‑end web‑scrape curation (NeMo)
```python
from nemo_curator import DocumentDataset
from nemo_curator.filters import *
from nemo_curator.modules import ExactDuplicates, FuzzyDuplicates
from nemo_curator.modifiers import PIIRedactor

# Load Common Crawl parquet shards
raw = DocumentDataset.read_parquet("s3://common-crawl/*.parquet")

pipeline = [
    WordCountFilter(min_words=100),
    RepeatedLinesFilter(max_repeated_line_fraction=0.2),
    UrlRatioFilter(max_url_ratio=0.3),
    LanguageIdentificationFilter(target_languages=["en"]),
    ExactDuplicates(id_field="id", text_field="text"),
    FuzzyDuplicates(id_field="id", text_field="text", num_hashes=260),
    PIIRedactor(),
]

for step in pipeline:
    raw = step(raw)

raw.to_parquet("s3://curated/common-crawl/")
```
### 2. Distributed preprocessing with Ray Data
```python
import ray

ray.init()

# Read, clean, embed, and write images
images = (
    ray.data.read_images("s3://raw-images/")
    .map_batches(lambda b: {"image": b["image"] / 255.0})
    .map_batches(lambda b: {"embed": my_clip_encoder(b["image"]).cpu().numpy()},
                 batch_size=64, num_gpus=1)
)

images.write_parquet("s3://curated/images/")
```
---

## Rules & Best Practices
- **Prefer Parquet** for large ML datasets; it stores columnar data efficiently and is natively supported by both tools.
- **GPU memory**: keep batch sizes small enough to fit the GPU (e.g., 64‑128 for image tensors). Increase batch size only after confirming no OOM.
- **Deduplication order**: run exact dedup first, then fuzzy, then semantic to avoid unnecessary expensive embeddings.
- **Threshold tuning**: start with conservative thresholds (e.g., fuzzy similarity 0.8, NSFW 0.9) and adjust after a manual sample review.
- **Repartition** before heavy transforms to match cluster cores: `ds = ds.repartition(num_blocks)`.
- **Streaming**: use `iter_batches` for datasets larger than memory; avoid calling `.to_pandas()` on the whole set.
- **Schema consistency**: ensure all shards share the same column names and types; mismatched schemas cause runtime errors.
- **Validate redaction**: after PII/NSFW steps, run a quick audit on a random sample to confirm removal.
- **Monitor costs**: GPU clusters are faster but more expensive; benchmark a small subset before scaling.
---

## Pitfalls to Avoid
- **Over‑filtering**: aggressive heuristics can discard useful data. Review filter statistics before final run.
- **Embedding drift**: semantic dedup uses a fixed embedding model; if the model is outdated, similarity scores may be inaccurate.
- **GPU contention**: launching many concurrent `map_batches` with `num_gpus=1` on a node with limited GPUs leads to queuing. Limit concurrent tasks or use `ray.init(num_gpus=total)`.
- **Inconsistent IDs**: dedup modules rely on `id_field`. Missing or duplicate IDs break exact dedup.
- **File format mismatch**: Ray Data cannot write images directly; convert to a supported format (e.g., Parquet with binary blobs) before export.
---

## Checklist
- [ ] Install `nemo-curator` (GPU) **or** `ray[data]` (distributed).
- [ ] Verify CUDA drivers and GPU visibility (`nvidia-smi`).
- [ ] Define quality filters (word count, URL ratio, language).
- [ ] Choose dedup method: exact → fuzzy → semantic.
- [ ] Configure PII/NSFW redaction modules.
- [ ] Set up cluster:
    - Ray: `ray.init()` or submit to a Ray cluster.
    - NeMo: `client = get_client(cluster_type="gpu", n_workers=N)`.
- [ ] Tune batch size and number of partitions.
- [ ] Run a small pilot to measure runtime and memory.
- [ ] Execute full pipeline.
- [ ] Write output to Parquet.
- [ ] Perform a random sample audit for quality and redaction.
- [ ] Clean up cluster resources.
