@REF:pytorch-patterns
§USE{PyTorch_2.15+|new_models/train_scripts|DL_review|debug(train_loop,data_pipe,num_div)|opt(GPU_mem,speed,dist)|export/serve|repro_exp}
§R{
  device_agnostic⇒device=torch.accelerator.current_accelerator() if torch.accelerator.is_available() else torch.device("cpu");move_model_once(≺loop)∧¬hardcode_.cuda();
  sync_mem⇒torch.accelerator.synchronize()∧torch.accelerator.memory_stats()∧torch.accelerator.Graph(≥2.12);
  repro⇒set_seed(seed=42)→{torch.manual_seed,np.random.seed,random.seed,torch.use_deterministic_algorithms(True,warn_only=True)};
  shapes⇒doc∧assert_tensor_shapes_in_forward;use(x.flatten(1)∨x.reshape(...))¬fragile_x.view();
  module⇒define_layers∈__init__∧¬create_weights_in_forward∧¬inplace_activations_on_residual_paths;
  init⇒model.apply(_init_weights)→{Linear/Conv2d:kaiming_normal_(weight,mode="fan_out",nonlinearity="relu")∧zeros_(Linear.bias);Norm:ones_(weight)∧zeros_(bias)};
  attn⇒F.scaled_dot_product_attention(SDPA)∨FlexAttention(FlashAttention-4≥2.11)¬manual_softmax(Q@K.T)
}
§D{
  amp_modern_hw(Ampere+|Hopper|Blackwell|XPU)⇒autocast(device.type,dtype=torch.bfloat16)∧¬GradScaler¬fp16_by_habit;
  amp_legacy_hw(V100|FP16_only)⇒autocast(device.type,dtype=torch.float16)+torch.amp.GradScaler(device.type)¬unscaled_fp16;
  eval∨infer⇒@torch.inference_mode()+model.eval()¬torch.no_grad()_only;
  weights_persist⇒safetensors(zero_copy,safe)∨torch.load(...,map_location="cpu",weights_only=True)(def≥2.6)+safe_globals¬weights_only=False_untrusted|torch.save(model);
  dist_train⇒DDP(fits_VRAM)∨FSDP2(torch.distributed.fsdp.fully_shard+DTensor)¬DataParallel|legacy_FSDP1;
  dist_ckpt⇒torch.distributed.checkpoint(DCP,sharded_async)¬rank0_gather_torch.save;
  resumable_ingest⇒torchdata.stateful_dataloader.StatefulDataLoader¬removed_DataPipes|stateless_resume;
  prod_export⇒torch.export+AOTInductor|ExecuTorch|torch.onnx.export(...,dynamo=True)¬deprecated_TorchScript(≥2.10);
  num_divergence⇒torch.utils._debug_mode.DebugMode(≥2.10)∨detect_anomaly(dev_only)¬guess;
}
§PAT:loop{
```python
def train_one_epoch(model: nn.Module, loader: DataLoader, opt: torch.optim.Optimizer, crit: nn.Module, device: torch.device, amp_dtype: torch.dtype | None = torch.bfloat16, scaler: torch.amp.GradScaler | None = None) -> float:
    model.train(); total_loss = 0.0; nb = device.type != "cpu"
    for x, y in loader:
        x, y = x.to(device, non_blocking=nb), y.to(device, non_blocking=nb)
        opt.zero_grad(set_to_none=True)
        with torch.amp.autocast(device_type=device.type, dtype=amp_dtype, enabled=amp_dtype is not None):
            loss = crit(model(x), y)
        if scaler is not None:  # FP16 only; omit for BF16
            scaler.scale(loss).backward(); scaler.unscale_(opt)
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(opt); scaler.update()
        else:
            loss.backward(); torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0); opt.step()
        total_loss += loss.item()
    return total_loss / len(loader)

@torch.inference_mode()
def evaluate(model: nn.Module, loader: DataLoader, crit: nn.Module, device: torch.device, amp_dtype: torch.dtype | None = torch.bfloat16) -> tuple[float, float]:
    model.eval(); total_loss = 0.0; correct = 0; total = 0; nb = device.type != "cpu"
    for x, y in loader:
        x, y = x.to(device, non_blocking=nb), y.to(device, non_blocking=nb)
        with torch.amp.autocast(device_type=device.type, dtype=amp_dtype, enabled=amp_dtype is not None):
            out = model(x); loss = crit(out, y)
        total_loss += loss.item(); correct += (out.argmax(1) == y).sum().item(); total += y.size(0)
    return total_loss / len(loader), correct / total
```
}
§DATA{
  Dataset:type_hinted(__init__,__len__,__getitem__:Image.open().convert("RGB")→transform);
  DataLoader(ds,batch_size=32,shuffle=True,num_workers=4,pin_memory=device.type!="cpu",persistent_workers=True,prefetch_factor=2,drop_last=True,worker_init_fn=seed_worker);
  resumable:from torchdata.stateful_dataloader import StatefulDataLoader;#ckpt_dataloader.state_dict()_for_exact_mid_epoch_resume;
  var_len:nn.utils.rnn.pad_sequence(seqs,batch_first=True,padding_value=0)∨varlen_attn(≥2.10,ragged/packed)
}
§CKPT{
  weights_safe:from safetensors.torch import save_file,load_file;save_file(model.state_dict(),"model.safetensors");#zero_copy∧¬pickle;
  train_state_1node:torch.save({"epoch":ep,"model_state_dict":model.state_dict(),"optimizer_state_dict":opt.state_dict(),"loss":float(loss)},path);#pure_tensors/primitives⇒loads_under_weights_only=True;
  load_safe:ckpt=torch.load(path,map_location="cpu",weights_only=True)→model.load_state_dict(ckpt["model_state_dict"])∧(opt⇒opt.load_state_dict(ckpt["optimizer_state_dict"]));
  dist_sharded:torch.distributed.checkpoint(DCP).save/load(state_dict,storage_writer/reader)#FSDP2/TP_async_sharded
}
§DIST{
  single_node_fits:DistributedDataParallel(DDP)+torchrun;
  sharded_large:FSDP2(torch.distributed.fsdp.fully_shard_on_DTensor,fp32_master_weights_opt,overlap_reduce_scatter/all_gather);
  hang_diag:PyTorch_2.15+_rewritten_NCCL_default_with_flight_recorder
}
§EXPORT{
  non_py_cpp_server:torch.export.export(model,example_args)→AOTInductor(PT2_Archive,freezing,CUTLASS/Triton);
  edge_mobile:torch.export→ExecuTorch;
  cross_fw_ort:torch.onnx.export(model,example_args,"model.onnx",dynamo=True)→ONNX_Runtime;
  quant_deploy:FP8(float8_e4m3fn)|NVFP4(Blackwell)|Microscaling(MX)_in_torch.export.save(≥2.12)
}
§PERF{
  compile:torch.compile(model,mode="default"|"reduce-overhead"|"max-autotune");#Py3.14/3.15_ready;torch.compiler.set_stance;
  optim:torch.optim.AdamW(params,lr=...,fused=True)#Adagrad_fused≥2.12;
  grad_ckpt:from torch.utils.checkpoint import checkpoint;checkpoint(self.block,x,use_reentrant=False);
  profile:{torch.profiler,torch.accelerator.memory_stats(),DebugMode(≥2.10)}
}
§ANTI{
  val_in_model.train()⇒always_model.eval()+@torch.inference_mode();
  inplace_ops_breaking_autograd(nn.ReLU(inplace=True),F.relu(...,inplace=True),x+=residual)⇒out_of_place;
  hardcoded_.cuda()_or_model.cuda()_in_loop⇒torch.accelerator+move_once_≺loop;
  .item()_≺backward(detaches_graph)⇒.item()_post_backward_for_log_only;
  torch.save(model,path)∨weights_only=False_on_untrusted⇒safetensors|state_dict+weights_only=True;
  TorchScript(torch.jit.script/trace)_for_new_deployments(deprecated≥2.10)⇒torch.export+AOTInductor|ONNX(dynamo=True);
  DataParallel⇒DDP|FSDP2;
  fp16_sans_GradScaler∨GradScaler_with_bfloat16⇒bf16_alone|fp16+GradScaler
}
§CHK{
  [ ]torch.accelerator_device_agnostic;[ ]bf16_or_fp16+GradScaler;[ ]inference_mode+model.eval();[ ]non_blocking+pin_memory;[ ]safetensors|weights_only=True|DCP;[ ]torch.export|ONNX(dynamo=True)¬TorchScript;[ ]shape+determinism_tests
}
