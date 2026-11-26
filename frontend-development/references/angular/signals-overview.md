@REF:signals-overview

§API{
  writable:`import{signal}from'@angular/core'`;`c=signal(0)`;read`c()`;`c.set(3)`;`c.update(v=>v+1)`;
  readonly_svc:`private readonly _c=signal(0); readonly c=this._c.asReadonly();`(blocks`.set`/`.update`);
  computed:`import{computed}from'@angular/core'`;`dbl=computed(()=>c()*2)`(read_only∧lazy_eval∧memoized∧dynamic_deps_only_read_sigs_tracked);
  untracked:`import{effect,untracked}from'@angular/core'`;`effect(()=>log(user(),untracked(cnt)))`(no_dep_on`cnt`)
}
§R{
  reactive_contexts(auto_track_reads):`computed`|`effect`|`linkedSignal`|component_templates;
  reactive_ctx_active_SYNC_ONLY⇒reads_after`await`NOT_tracked⇒ALWAYS_read_signals_BEFORE`await`
}
§PAT{
```ts
effect(async () => {
  const cur = theme();
  await fetchUserData();
  console.log(cur);
});
```
}
