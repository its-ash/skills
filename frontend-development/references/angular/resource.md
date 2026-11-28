@REF:resource
§R{
stable_v22(@angular/core:`resource`,@angular/common/http:`httpResource`,@angular/core/rxjs-interop:`rxResource`);async_fetch→signal_reactivity;
params=reactive_fn→Δ_refetch;loader=async({params,abortSignal});
params_Δ_in_flight⇒aborts_prev(ALWAYS_pass_abortSignal→fetch);
reload():rerun_without_params_Δ;value.set(v):optimistic_mut→status='local';
HttpClient(Fetch_API_default_v22)⇒prefer(`httpResource`)[interceptors+signal_states+OnPush_auto-dirty]
}
§PAT{
```ts
import{httpResource}from'@angular/common/http';
import{resource,signal,computed}from'@angular/core';
id=signal('123');
// Preferred for HTTP (interceptors + Fetch default):
user=httpResource<User>(() => `/api/users/${this.id()}`);
// Generic async resource:
r=resource({
  params:()=>({id:this.id()}),
  loader:async({params,abortSignal})=>{
    const res=await fetch(`/api/users/${params.id}`,{signal:abortSignal});
    if(!res.ok)throw new Error('Network error');
    return res.json();
  }
});
name=computed(()=>this.r.hasValue()?this.r.value()?.name:'Loading...');
```
}
§API{value():T|undefined;hasValue():bool;isLoading():bool;error():unknown|undefined;status():'idle'|'loading'|'resolved'|'error'|'reloading'|'local'}
