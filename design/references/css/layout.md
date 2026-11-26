@REF:layout
§R{
2D⇒Grid;1D⇒Flex;gutters⇒gap(flex|grid|multi-col)∧¬child_margins;
shrink_track⇒minmax(0,1fr)(¬1fr,long_words/<pre>/wide_img);
logical⇒margin-inline,padding-block,inset-inline-start,inline-size(RTL/vertical);
interactive⇒¬reorder(order,row-reverse,grid-auto-flow:dense;focus=DOM_order);
flex_text/scroller⇒min-width:0|min-inline-size:0(default auto blocks shrink);
aspect-ratio reserves media/card(width+height both axes overrides);
stacking⇒isolation:isolate∧¬z-index escalation;
sticky⇒req inset(top:0)∧fails if ancestor overflow∈{hidden,auto,scroll}→overflow:clip;
clip_sans_scroll⇒overflow:clip>hidden(+overflow-clip-margin);
display:contents⇒drops box(bg,border,padding)∧¬interactive_els
}
§PAT:Flexbox{
.row{display:flex;flex-wrap:wrap;gap:1rem;align-items:center} .grow{flex:1} .fixed{flex:0 0 15rem} .push{margin-inline-start:auto};
flex:1⇒basis:0(equal);flex:auto⇒content_sized;wrap_fill(no_MQ)⇒flex:1 1 20rem;
space-between+wrap⇒last-row gap→Grid auto-fill;flex-wrap:balance=exp_Chrome
}
§PAT:Grid{
repeat(auto-fill,minmax(min(100%,16rem),1fr))(auto-fill keeps empty tracks;auto-fit collapses/stretches;min(100%,…) prevents overflow);
shell:grid-template:"head head" auto "side main" 1fr "foot foot" auto/15rem minmax(0,1fr);min-block-size:100dvh;grid-area:head;
stack⇒children grid-area:1/1(sizes to largest);
bleed:grid-template-columns:[full-start]minmax(1rem,1fr)[content-start]min(65ch,100% - 2rem)[content-end]minmax(1rem,1fr)[full-end];grid-column:content|full(¬100vw scrollbar overflow);
subgrid:grid-row:span 3;grid-template-rows:subgrid(Baseline 2023:Chrome 117,FF 71,Safari 16);
masonry:@supports(display:grid-lanes){display:grid-lanes}(exp,fallback grid/multi-col);
gap_decor:column-rule/row-rule+(-inset,-break,-outset),gap-rule-paint-order(Chrome/Edge 149+)
}
§PAT:MultiCol_Sizing{
columns:18rem;column-gap:2rem;column-rule:1px solid var(--line);break-inside:avoid;column-span:all;
column-height+column-wrap:wrap(Chrome 145+)⇒vertical wrap row;
intrinsic:min-content,max-content,fit-content|fit-content(20rem);
width:stretch(fills CB respecting margins≠100%)⇒declare -webkit-fill-available first(Safari);
interpolate-size:allow-keywords on :root⇒animate auto/min-content/stretch(Chromium)
}
§PAT:Center_Pos_Stack{
center⇒grid(place-items:center)|flex(justify-content:center;align-items:center)|abs(inset:0;margin:auto;inline-size:fit-content;block-size:fit-content)|block(align-content:center,Baseline 2024);
align-items:safe center;text-box:trim-both cap alphabetic(→typography);inset:0≡top/right/bottom/left:0;
abs_CB⇒ancestor(position≠static|transform|filter|contain:layout|paint|container-type);
fixed_CB⇒viewport unless ancestor(transform|filter|perspective|contain|will-change:transform);
popups⇒anchor_pos(→components-ui);
stacking_ctx⇒(position+z-index≠auto)|opacity<1|transform|filter|mix-blend-mode|isolation:isolate|contain:paint|will-change(those)|flex/grid_child+z-index;
z-index local to ctx;--z-dropdown:10;--z-modal:100;top_layer(showModal(),popover)>z-index;
overflow:auto;scrollbar-gutter:stable;overscroll-behavior:contain
}
§ANTI{
% height req definite parent height(stretched flex/grid counts);
100vh on mobile includes UA bar→100dvh|100svh;
margins collapse in block flow,never flex/grid;gap∉block_flow→>*+*|flex_col+gap;
ancestor transform breaks position:fixed/sticky
}
