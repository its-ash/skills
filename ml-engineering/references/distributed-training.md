# Distributed Training with Accelerate, DeepSpeed, FSDP, Lightning, Megatron‑Core, and Ray Train

This skill helps you add distributed training to PyTorch projects, select the right library for your hardware and model size, and avoid common pitfalls. It covers:
* Accelerate – 4‑line conversion for any hardware.
* DeepSpeed – ZeRO stages, DeepNVMe I/O, and FP8 support.
* Fully Sharded Data Parallel (FSDP) – native PyTorch sharding.
* PyTorch Lightning – high‑level Trainer with callbacks.
* Megatron‑Core – 3‑D parallelism for billion‑parameter LLMs.
* Ray Train – multi‑node orchestration, fault tolerance, and hyper‑parameter tuning.

---
## When to use
| Scenario | Recommended tool |
|----------|-----------------|
| Quick prototype, minimal code changes, any hardware (CPU, single‑GPU, multi‑GPU, TPU) | **Accelerate** |
| Large models (≤ 100 B) needing ZeRO optimizer, FP8, or fast NVMe checkpoint I/O | **DeepSpeed** |
| Native PyTorch, need fine‑grained sharding, CPU offload, or custom process groups | **FSDP** |
| Want clean training loops, built‑in logging, callbacks, and easy multi‑node scaling | **PyTorch Lightning** |
| Training LLMs > 10 B parameters, require tensor/pipeline/context/expert parallelism for maximum throughput | **Megatron‑Core** |
| Scale any framework across many nodes, need fault tolerance, elastic scaling, or distributed hyper‑parameter search | **Ray Train** |

---
## Common workflows
### 1. Accelerate – minimal conversion
```python
import torch
from accelerate import Accelerator

accelerator = Accelerator()  # optional: mixed_precision='fp16' | 'bf16' | 'fp8'
model = torch.nn.Linear(10, 2)
optimizer = torch.optim.Adam(model.parameters())
loader = torch.utils.data.DataLoader(dataset, batch_size=32)

model, optimizer, loader = accelerator.prepare(model, optimizer, loader)

for batch in loader:
    optimizer.zero_grad()
    loss = model(batch).mean()
    accelerator.backward(loss)
    optimizer.step()
```
Run with a single command:
```
accelerate launch train.py
```
*No manual `.to('cuda')` or `loss.backward()` needed.*

### 2. DeepSpeed – ZeRO‑2/3 and DeepNVMe I/O
```python
from accelerate import Accelerator

accelerator = Accelerator(
    mixed_precision='bf16',
    deepspeed_plugin={
        "zero_stage": 2,
        "gradient_accumulation_steps": 4,
        "offload_optimizer": False,
    },
)
model, optimizer, loader = accelerator.prepare(model, optimizer, loader)
```
**DeepNVMe checkpoint example** (requires DeepSpeed ≥ 0.15.0):
```python
from deepspeed.ops.op_builder import AsyncIOBuilder
h = AsyncIOBuilder().load().aio_handle()
# Write a tensor to NVMe (blocking)
h.sync_pwrite(tensor, '/nvme/checkpoint.pt')
# Non‑blocking write
h.async_pwrite(tensor, '/nvme/checkpoint.pt')
h.wait()  # synchronize
```
Launch with optional config file:
```
accelerate launch --config_file ds_config.json train.py
```

### 3. Fully Sharded Data Parallel (FSDP)
```python
import torch
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP
from torch.distributed.fsdp import ShardingStrategy

model = MyModel()
fsdp_model = FSDP(
    model,
    sharding_strategy=ShardingStrategy.FULL_SHARD,  # ZeRO‑3 equivalent
    cpu_offload=False,
)
optimizer = torch.optim.Adam(fsdp_model.parameters())
```
Initialize the process group before creating the FSDP model:
```python
import torch.distributed as dist

dist.init_process_group(backend='nccl')
```
Use the same training loop as in single‑process code; FSDP handles parameter sharding and gradient reduction.

### 4. PyTorch Lightning – Trainer abstraction
```python
import lightning as L
import torch.nn as nn

class LitModel(L.LightningModule):
    def __init__(self):
        super().__init__()
        self.net = nn.Linear(28*28, 10)
    def training_step(self, batch, batch_idx):
        x, y = batch
        loss = nn.functional.cross_entropy(self.net(x), y)
        self.log('train_loss', loss)
        return loss
    def configure_optimizers(self):
        return torch.optim.Adam(self.parameters(), lr=1e-3)

trainer = L.Trainer(
    max_epochs=10,
    accelerator='gpu',
    devices=8,               # DDP across 8 GPUs
    strategy='ddp',         # or 'fsdp', 'deepspeed'
    precision='bf16',
    accumulate_grad_batches=4,
)
trainer.fit(LitModel(), train_dataloader)
```
Lightning automatically creates checkpoints, logs metrics, and supports callbacks such as `ModelCheckpoint` and `EarlyStopping`.

### 5. Megatron‑Core – 3‑D parallelism for LLMs
```bash
# Example launch for a 70B model (64 GPUs)
GPUS_PER_NODE=8
NNODES=8
TP=4   # tensor parallel
PP=4   # pipeline parallel
CP=1   # context parallel

torchrun \
  --nproc_per_node=$GPUS_PER_NODE \
  --nnodes=$NNODES \
  pretrain_gpt.py \
  --tensor-model-parallel-size $TP \
  --pipeline-model-parallel-size $PP \
  --context-parallel-size $CP \
  --sequence-parallel \
  --bf16 \
  --use-mcore-models \
  --transformer-impl transformer_engine \
  --micro-batch-size 1 \
  --global-batch-size 1024 \
  --lr 3e-4 \
  ...
```
Key flags:
* `--tensor-model-parallel-size` – split model weights across GPUs.
* `--pipeline-model-parallel-size` – split layers into pipeline stages.
* `--context-parallel-size` – split long sequences.
* `--fp8-hybrid` – enable FP8 on Hopper/Ada GPUs.
* `--sequence-parallel` – reduce activation memory.

### 6. Ray Train – multi‑node orchestration & hyper‑parameter tuning
```python
import ray
from ray import train
from ray.train import ScalingConfig
from ray.train.torch import TorchTrainer
import torch.nn as nn

def train_func(config):
    model = nn.Linear(10, 1)
    optimizer = torch.optim.SGD(model.parameters(), lr=config["lr"])
    model = train.torch.prepare_model(model)
    for epoch in range(10):
        loss = model(torch.randn(32, 10)).sum()
        loss.backward()
        optimizer.step()
        optimizer.zero_grad()
        train.report({"loss": loss.item()}, step=epoch)

trainer = TorchTrainer(
    train_func,
    scaling_config=ScalingConfig(num_workers=8, use_gpu=True),
    run_config=train.RunConfig(name="my_experiment"),
)
trainer.fit()
```
**Hyper‑parameter search** with Ray Tune:
```python
from ray import tune
from ray.tune.schedulers import ASHAScheduler

param_space = {"lr": tune.loguniform(1e-5, 1e-2), "batch_size": tune.choice([16,32,64])}

tuner = tune.Tuner(
    TorchTrainer(train_func, scaling_config=ScalingConfig(num_workers=4, use_gpu=True)),
    param_space=param_space,
    tune_config=tune.TuneConfig(num_samples=20, scheduler=ASHAScheduler(metric="loss", mode="min")),
)
results = tuner.fit()
print("Best config:", results.get_best_result(metric="loss", mode="min").config)
```
Ray automatically handles checkpointing, fault recovery, and elastic scaling.

---
## Rules & best practices
* **Initialize the process group once, before any model creation.** Use `torch.distributed.init_process_group(backend='nccl')` for GPU clusters.
* **Never call `.to('cuda')` after `accelerator.prepare` or `prepare_model`.** The library moves data automatically.
* **Set a fixed random seed on all ranks** to obtain reproducible results:
  ```python
  from accelerate.utils import set_seed
  set_seed(42)
  ```
* **Use gradient accumulation when the effective batch size exceeds GPU memory.**
  *Accelerate*: `accelerator = Accelerator(gradient_accumulation_steps=4)` and wrap the loop with `with accelerator.accumulate(model):`.
  *Lightning*: `accumulate_grad_batches=4`.
  *DeepSpeed*: set `gradient_accumulation_steps` in the plugin config.
* **Checkpoint only on the main process** (rank 0) to avoid duplicate files.
  ```python
  if accelerator.is_main_process:
      accelerator.save_state('ckpt/')
  ```
* **For DeepSpeed DeepNVMe I/O, always call `h.wait()` after non‑blocking writes/reads** to avoid data races.
* **Choose the correct NCCL/Gloo backend**:
  * Use `nccl` for CUDA GPUs.
  * Use `gloo` for CPU or when NCCL fails.
* **Monitor GPU utilization**. Low MFU (<30 %) usually means micro‑batch is too small or parallelism overhead is too high.
* **When mixing strategies (e.g., FSDP + DeepSpeed), configure only one optimizer‑sharding method** to prevent conflicts.

---
## Pitfalls & how to fix them
| Symptom | Common cause | Fix |
|---------|---------------|-----|
| `RuntimeError: NCCL error` | Mismatched NCCL versions or missing InfiniBand support | Set `NCCL_DEBUG=INFO` and ensure all nodes have the same NCCL library. Fallback to `gloo` if needed. |
| No speedup on multi‑GPU | `batch.to('cuda')` still present, preventing automatic device placement | Remove manual `.to()` calls; rely on `accelerator.prepare` or `prepare_model`. |
| Gradient accumulation ineffective | Missing `accelerator.accumulate` context or `accumulate_grad_batches` flag | Wrap training step in the appropriate context manager. |
| Checkpoint files corrupted | Using non‑blocking `async_pwrite` without `h.wait()` before modifying the tensor | Call `h.wait()` after each async write/read. |
| OOM on large LLMs | Tensor parallel size too low or micro‑batch too large | Increase tensor parallelism, enable `sequence-parallel`, or reduce `micro-batch-size`. |
| Training diverges on FP8 | FP8 not supported on the GPU or missing transformer‑engine plugin | Use BF16 on non‑Hopper GPUs; install `transformer_engine` and set `--fp8-hybrid` only on Hopper/Ada. |

---
## Checklist for a new distributed training run
1. **Select framework** based on model size and workflow (see table above).  
2. **Install required packages** (`pip install accelerate deepspeed lightning ray[train] megatron-core`).  
3. **Write or adapt the training script**:
   * Add `Accelerator`, `prepare_model`, or `LightningModule` as required.
   * Wrap optimizer step with the framework’s backward call.
4. **Configure mixed precision** (`mixed_precision='fp16'/'bf16'/'fp8'`).  
5. **Set gradient accumulation** if needed.  
6. **Create a config file** (optional) for DeepSpeed or Megatron‑Core hyper‑parameters.  
7. **Initialize the process group** (only for FSDP or raw DDP).  
8. **Run a single‑node test** to verify loss decreases.  
9. **Scale up**:
   * Accelerate – `accelerate launch --multi_gpu --num_processes N train.py`
   * DeepSpeed – `deepspeed --num_gpus N train.py`
   * Lightning – set `devices=N, strategy='ddp'`
   * Megatron‑Core – use `torchrun` with `--nnodes` and parallelism flags.
   * Ray Train – adjust `ScalingConfig(num_workers=N)`.  
10. **Monitor metrics** (loss, GPU utilization, MFU).  
11. **Checkpoint** on the main rank after each epoch or every few steps.  
12. **Validate reproducibility** by fixing seeds and checking that all ranks report the same loss.

---
## References
* Accelerate docs: https://huggingface.co/docs/accelerate
* DeepSpeed docs: https://www.deepspeed.ai
* PyTorch FSDP docs: https://pytorch.org/docs/stable/fsdp.html
* Lightning docs: https://lightning.ai/docs/pytorch/stable/
* Megatron‑Core docs: https://docs.nvidia.com/megatron-core/
* Ray Train docs: https://docs.ray.io/en/latest/train.html
