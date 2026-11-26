@REF:linked-signal
§R{
  `linkedSignal`(@angular/core)→writable_signal(.set(),.update())∧derived_default_from_src;
  src_Δ⇒reset_to_computed_val;
  ¬use(`effect`)_to_sync_state⇒anti-pattern
}
§PAT{
  basic:```ts
import { signal, linkedSignal } from '@angular/core';
selectedOption = linkedSignal(() => this.shippingOptions()[0]);
this.selectedOption.set(this.shippingOptions()[i]);
```
  prev_state(source+computation):```ts
selectedOption = linkedSignal<ShippingMethod[], ShippingMethod>({
  source: this.shippingOptions,
  computation: (next, prev) => next.find(o => o.id === prev?.value.id) ?? next[0],
}); // prev contains previous source value & previous linkedSignal value (prev?.value)
```
}
§D{
  strict_derived∧¬manual_Δ⇒`computed`;
  derived_default∧user_override⇒`linkedSignal`;
  sync_state_A→B⇒`computed`⊕`linkedSignal`∧¬`effect`
}
