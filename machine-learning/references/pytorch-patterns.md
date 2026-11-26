@REF:pytorch-patterns
§USE{new_models/train_scripts|DL_review|debug(train_loop,data_pipe)|opt(GPU_mem,speed)|repro_exp}
§CORE{
  device_agnostic:device=torch.device("cuda" if torch.cuda.is_available() else "cpu");move_model_once(≺loop),¬hardcode_.cuda();
  repro:set_seed(seed=42)→{torch.manual_seed,torch.cuda.manual_seed_all,np.random.seed,random.seed,cudnn.deterministic=True,cudnn.benchmark=False};
  shapes:doc∧verify_tensor_shapes_in_forward(e.g.(B,C,H,W)→x.view(x.size(0),-1)→(B,num_classes))
}
§ARCH{
  module:define_layers∈__init__(nn.Sequential,nn.Conv2d,nn.BatchNorm2d,nn.ReLU(inplace=True),nn.MaxPool2d,nn.Dropout,nn.Linear),¬create_weights_in_forward;
  init:model.apply(_init_weights)→{Linear/Conv2d:kaiming_normal_(weight,mode="fan_out",nonlinearity="relu")∧zeros_(Linear.bias);BatchNorm2d:ones_(weight)∧zeros_(bias)}
}
§LOOP{
```python
def train_one_epoch(model: nn.Module, dataloader: DataLoader, optimizer: torch.optim.Optimizer, criterion: nn.Module, device: torch.device, scaler: torch.amp.GradScaler | None = None) -> float:
    model.train(); total_loss = 0.0
    for data, target in dataloader:
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad(set_to_none=True)
        with torch.amp.autocast("cuda", enabled=scaler is not None):
            loss = criterion(model(data), target)
        if scaler is not None:
            scaler.scale(loss).backward(); scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(optimizer); scaler.update()
        else:
            loss.backward(); torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0); optimizer.step()
        total_loss += loss.item()
    return total_loss / len(dataloader)

@torch.no_grad()
def evaluate(model: nn.Module, dataloader: DataLoader, criterion: nn.Module, device: torch.device) -> tuple[float, float]:
    model.eval(); total_loss = 0.0; correct = 0; total = 0
    for data, target in dataloader:
        data, target = data.to(device), target.to(device)
        out = model(data)
        total_loss += criterion(out, target).item()
        correct += (out.argmax(1) == target).sum().item(); total += target.size(0)
    return total_loss / len(dataloader), correct / total
```
}
§DATA{
  Dataset:type_hinted(__init__,__len__,__getitem__:Image.open().convert("RGB")→transform);
  DataLoader(dataset,batch_size=32,shuffle=True,num_workers=4,pin_memory=True,persistent_workers=True,drop_last=True);#drop_last=True⇒consistent_BN_batch
  var_len_collate:nn.utils.rnn.pad_sequence(sequences,batch_first=True,padding_value=0)
}
§CKPT{
  save:torch.save({"epoch":epoch,"model_state_dict":model.state_dict(),"optimizer_state_dict":optimizer.state_dict(),"loss":loss},path);#¬save_entire_model;¬weights_only_if_resuming
  load:ckpt=torch.load(path,map_location="cpu",weights_only=True)→model.load_state_dict(ckpt["model_state_dict"])∧(optimizer⇒optimizer.load_state_dict(ckpt["optimizer_state_dict"]))
}
§PERF{
  AMP:torch.amp.GradScaler("cuda")+torch.amp.autocast("cuda")⇒~2x_speed;
  grad_ckpt:from torch.utils.checkpoint import checkpoint;checkpoint(self.block,x,use_reentrant=False);#trade_compute_for_mem
  compile:torch.compile(model,mode="reduce-overhead");#PyTorch≥2.0;modes∈{"default"(safe),"reduce-overhead"(faster),"max-autotune"(fastest)}
  profile:{torch.profiler,torch.cuda.memory_summary()}
}
§ANTI{
  val_in_model.train()(dropout_active,BN_uses_batch_stats)⇒always_model.eval()+torch.no_grad();
  inplace_ops_breaking_autograd(F.relu(...,inplace=True),x+=residual)⇒out_of_place(F.relu(x),x=x+residual);
  model.cuda()_inside_loop⇒model.to(device)_once_≺loop;
  .item()_≺backward(detaches_graph)⇒.item()_post_backward_for_log_only;
  torch.save(model,path)(fragile/non_portable)⇒save_state_dict
}
