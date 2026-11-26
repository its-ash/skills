@REF:resource
§R{
experimental(@angular/core);async_fetch→signal_reactivity;
params=reactive_fn→Δ_refetch;loader=async({params,abortSignal});
params_Δ_in_flight⇒aborts_prev(ALWAYS_pass_abortSignal→fetch);
reload():rerun_without_params_Δ;value.set(v):optimistic_mut→status='local';
HttpClient⇒prefer(httpResource)[interceptors+same_API]
}
§PAT{
```ts
import{resource,signal,computed}from'@angular/core';
id=signal('123');
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
