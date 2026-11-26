@REF:route-animations
§R{
View_Transitions_API[progressive:unsupported→routes_no_anim];
enable:provideRouter(routes,withViewTransitions());
flow:snap(old)→DOM_Δ(activate_new)→snap(new)→animate;
CSS:GLOBAL(styles.css)¬component[encapsulation];shared⇒unique(view-transition-name)
}
§CFG{
```ts
provideRouter(routes,withViewTransitions({onViewTransitionCreated:({transition,from,to})=>{if(to.url==='/no-animation')transition.skipTransition();}}));
```
```css
::view-transition-old(root){animation:90ms cubic-bezier(0.4,0,1,1) both fade-out}
::view-transition-new(root){animation:210ms cubic-bezier(0,0,0.2,1) 90ms both fade-in}
```
}
