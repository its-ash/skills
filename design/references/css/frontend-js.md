@REF:frontend-js
§R{
HTML/CSS>JS(dialog,popover,details,:has(),invokers,scroll-anim);
state⇒attrs/classes(dataset.state,classList.toggle('is-open',open),aria-expanded);styles∈CSS;
dyn⇒el.style.setProperty('--k',v)∧¬bulk_inline;
¬untrusted(innerHTML|insertAdjacentHTML)→textContent|createElement|Sanitizer|setHTML();
¬innerHTML+=⇒reparses+drops_listeners→append()|insertAdjacentHTML('beforeend',trusted);
delegation⇒container_listener+e.target.closest(sel)+contains;
observers(IntersectionObserver|ResizeObserver|MutationObserver)>polling/scroll/resize→.disconnect();
cleanup⇒AbortController:{signal}(addEventListener,fetch)→abort();
detect⇒'popover'in HTMLElement.prototype|CSS.supports('anchor-name: --a')|document.startViewTransition
}
§PAT:DOM{
querySelector|getElementById∧¬window.myId;<template>+content.cloneNode(true);el.replaceChildren(...nodes);
classList.replace(a,b)⇒false iff a∉el;click∧e.detail===0⇒kbd(Enter/Space);
PointerEvents(pointerdown|move|up,setPointerCapture)+CSS(touch-action:none)
}
§PAT:CSS_JS{
s=new CSSStyleSheet();s.replaceSync(':host{display:block}');shadowRoot.adoptedStyleSheets=[s];document.adoptedStyleSheets=[...document.adoptedStyleSheets,s];
getComputedStyle(el).getPropertyValue('--tok').trim();
CSS.registerProperty({name:'--x',syntax:'<length>',inherits:false,initialValue:'0px'})≡@property;
matchMedia('(prefers-reduced-motion: reduce)')+'change';CSS.supports('selector(::scroll-marker)');
CSS.highlights.set('k',new Highlight(...ranges))+::highlight(k)
}
§PAT:Observers{
IntersectionObserver(cb,{rootMargin:'0px 0px -10% 0px',threshold:0})→e.isIntersecting,.observe(el);
ResizeObserver(([e])=>e.target.style.setProperty('--w',e.contentBoxSize[0].inlineSize));
styling⇒CQ>ResizeObserver;ResizeObserver Δsize⇒loop_err→rAF|no-op_guard;
MutationObserver=batched_microtasks→light∧¬layout_reads
}
§PAT:WebComp_Shadow{
XCard extends HTMLElement:static observedAttributes=['v'];attachShadow({mode:'open'});connectedCallback()(idempotent);attributeChangedCallback()(if(this.isConnected));customElements.define('x-card',XCard);
tag∈'-';formAssociated=true+attachInternals()→setFormValue(),setValidity(),labels,internals.states.add('k')→:state(k);
DSD:<template shadowrootmode="open">;is="…"¬Safari→autonomous;
:host,:host(.a),:host([disabled]);:host-context()¬(FF|Safari)→inherited_props|attrs;
::slotted(sel)⇒direct_slotted_only(keeps lightDOM);<slot name="…">;
part="x"→::part(x)+exportparts;inherited(color,font,--*) cross;selectors¬cross;
:defined/:not(:defined)⇒anti-FOUC;CQ_in_shadow⇒:host{container-type:inline-size}
}
§PAT:VT_Focus_Net{
vt=document.startViewTransition({update,types:['slide']});await vt.finished(skip if ¬supported∨reduced-motion);
vt.ready⇒WAAPI on ::view-transition-*;el.startViewTransition()(Chrome 147+);
<dialog>=native_focus;custom⇒roving_tabindex(0/-1)+arrows;post-async⇒heading(tabindex=-1).focus({preventScroll:false});inert>focus_traps;
analytics⇒fetch(u,{keepalive:true})|navigator.sendBeacon(u,d)(¬custom_headers) on visibilitychange|pagehide(¬unload);
new URLPattern({pathname:'/product/:id'}).exec(location.href);
long_task⇒scheduler.yield()|setTimeout(0)|WebWorker(postMessage|Comlink)
}
§PAT:Frameworks_Test{
React:style={{'--accent':c}},focus(useEffect+refs),useDeferredValue/useTransition,¬runtime_CSS-in-JS_RSC;
Vue:color:v-bind(c),<style scoped>|CSS_Modules;Svelte:style:--accent={c},transition:fade,{css:t=>…}(CSS_anim);
Astro:scoped,define:vars={{c}},islands(client:visible|idle);
test⇒getByRole('button',{name:'Save'})(¬CSS_class;data-testid⇔∅a11y_query),Playwright toHaveScreenshot()+emulate(reduced-motion,color-scheme)
}
§ANTI{
offsetParent===null fails position:fixed→el.checkVisibility();
getBoundingClientRect() post-write⇒sync_layout→read_then_write;
passive_listener¬preventDefault()→{passive:false} iff scroll-block;Service/WebWorkers⇒∅DOM
}
