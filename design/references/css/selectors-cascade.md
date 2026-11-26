@REF:selectors-cascade
§R{
component⇒1_class(0,1,0);¬IDs,¬chains(.nav ul li a);
focus⇒:focus-visible∧¬remove_outline_sans_replacement;
form_err⇒:user-invalid/:user-valid(post-interact);
nesting⇒≤2-3 levels;¬concat(&__title invalid);
!important⇒utilities|override inline/3p only,in @layer
}
§PAT:Spec_Layers_Scope{
spec=(ID,class/attr/pseudo-class,el/pseudo-el);*,combinators,:where()=0;
:is(),:not(),:has(),:nth-child(… of S)=max(arg_spec);:root(0,1,0)>html(0,0,1);[id="x"]=class_spec;
bump(prefer layers)⇒.btn.btn|:is(.btn,#\#);
@layer reset,base,components,utilities;(declare once,first);@import url("r.css") layer(reset);@import url(v.css) layer(vendor);@layer components{…} @layer components.overrides{…};
cascade⇒later_layer>earlier(∀spec);unlayered>all_layers;!important reverses(earlier>later);
anon @layer{…}¬appendable;revert-layer⇒prev layer;Baseline 2022(Chrome 99,FF 97,Safari 15.4);Tailwind v4=@layer theme,base,components,utilities;
@scope(.card){:scope{…}img{…}} @scope(.tabs) to (.tab-panel){a{…}}(donut stops at inner;proximity wins ties;Chrome 118+,Safari 17.4+,FF)
}
§PAT:Nesting_Has{
.card{& h2{…}&:hover{…}.dark &{…}@media(width>=40rem){…}}(no_&≡descendant,el selectors late 2023;like :is(),#b elevates both;Baseline 2023);
:has()>JS_toggle(Baseline,¬@supports):.card:has(img)|form:has(:user-invalid) .submit|label:has(+ input:required)::after|html:has(dialog[open]){overflow:hidden}|li:has(+ li:hover),li:hover+li|.grid:has(> :nth-child(5));
:has()¬nested in :has(),¬pseudo-els;anchor close(.card:has(…))∧¬body:has(.x)|*:has(…)(re-runs on descendant Δ)
}
§PAT:Pseudos_Resets{
pseudo::focus-visible,:focus-within,:user-valid,:user-invalid,:placeholder-shown,:autofill,:checked,:indeterminate,:disabled,:read-only,:popover-open,:modal,:open(details,dialog,select),:target,:any-link,:defined,:nth-child(2 of .item),:not(.a,.b),:lang(ar),:dir(rtl);
pseudo_el::before/::after(content:"";¬img/input),::marker(color,font,content,white-space,anim/trans),::selection,::placeholder,::file-selector-button,::backdrop,::details-content,::highlight(k)(Custom Highlight API),::target-text(#:~:text=),::search-text(Chrome 144+);
reset(:where()|@layer reset):*,*::before,*::after{box-sizing:border-box}:where(body,h1-h4,p,figure,blockquote,dl,dd){margin:0}:where(ul,ol)[role="list"]{list-style:none;padding:0}:where(img,picture,video,canvas,svg){display:block;max-inline-size:100%}:where(input,button,textarea,select){font:inherit}:where(h1-h3){text-wrap:balance};
list-style:none breaks Safari/VO list→role="list"|list-style-type:"";
keywords:inherit,initial(spec≠UA),unset,revert(UA),revert-layer;all:revert>all:unset
}
§ANTI{
unknown pseudo-class in list(a:hover,a:unknown) drops rule→forgiving :is()/:where();
unlayered overrides @layers;large :is() elevates all branches;
@import precedes all rules except @charset and @layer statements
}
