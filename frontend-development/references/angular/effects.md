@REF:effects
§R{
  pkg:@angular/core;
  effect:sync_signal→imperative_non_signal_API{analytics,localStorage,sessionStorage,canvas,3rd_party_charts};
  exec:async(change_detection)∧runs≥1∧req(injection_context,e.g.constructor);
  cleanup:effect((onCleanup)=>{onCleanup(fn)})→runs_before(next_exec∨destroy);
  afterRenderEffect:runs_after_DOM_render(manual_DOM_inspect_modify)∧client_only(¬SSR)
}
§ANTI{
  ¬propagate_state_in_effect(.set()|.update()⇒ExpressionChangedAfterItHasBeenChecked∧infinite_loops)⇒use(computed()|linkedSignal())
}
§PAT{
  effect((onCleanup)=>{const t=setTimeout(f,1000);onCleanup(()=>clearTimeout(t))});
  canvas=viewChild.required<ElementRef>('canvas');
  afterRenderEffect({earlyRead:()=>this.canvas().nativeElement.getBoundingClientRect().width,write:(w)=>setupChart(this.canvas().nativeElement,w)})
}
§CFG{afterRenderEffect_phases(¬reflow):1:earlyRead→2:write(¬DOM_read)→3:mixedReadWrite(avoid)→4:read(¬DOM_write)}
