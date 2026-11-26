@REF:components-ui
§REL{[design](../SKILL.md)§4.4∧§7}
§R{
native:{<button>:act,<a href>:nav,<dialog>:modal,[popover]:light-dismiss,<details name>:accordion,<select>:pick};
modal:dialog.showModal()⇒top_layer,::backdrop,focus_in,Esc,inert_page(¬custom_trap);
overlay:popover+popovertarget⇒menus,toasts,tooltips(top_layer+light_dismiss_no_JS);
anchor:CSS_anchor+position-try-fallbacks(¬JS_coords);invokers:command/commandfor;inert:disable_subtree(bg/offscreen);
tabs:filled_rounded_in_muted_track(pad:4px,concentric_r)∧¬underline-only∧¬bare-text;
cards_callouts:tonal_surface+full_1px_hairline+uniform_pad∧¬one-sided_border(border-inline-start:4px)∧¬nested_cards;
forms:filled_accent(accent-color|filled_SVG)¬hollow_checked;appearance:base-select;keep_native_DOM;
¬modal_via_checkbox|:target;card_link:1_stretched_pseudo-el∧¬wrapping_<a>_w/_inner_links;
focus_ring::focus-visible{outline:2px solid var(--accent);outline-offset:2px}
}
§PAT{
tabs(ARIA:role=tablist/tab/tabpanel+aria-selected/controls+tabindex="-1"+Left/Right):
.tabs{gap:.25rem;padding:.25rem;border-radius:calc(var(--radius-control) + .25rem);background:var(--surface-muted)} .tab{border-radius:var(--radius-control);transition:150ms var(--ease-out)} .tab[aria-selected="true"]{background:var(--surface)};
cards(.card{position:relative;border-radius:var(--radius-card)}):
.card a.title::after{content:"";position:absolute;inset:0} .card:has(a.title:focus-visible)_ring .card .secondary-link{position:relative;z-index:1};
inset:.card-inset{border-radius:calc(var(--radius-card) - .5rem);background:var(--surface-muted)};
callout:.callout{border-radius:var(--radius-control);background:color-mix(in oklch,var(--accent) 10%,var(--surface));border:1px solid color-mix(in oklch,var(--accent) 22%,transparent)};
badge:.badge{border-radius:999px;text-box:trim-both cap alphabetic;background:color-mix(in oklch,var(--badge-tone,var(--accent)) 12%,transparent);color:var(--badge-tone,var(--accent));border:1px solid color-mix(in oklch,var(--badge-tone,var(--accent)) 20%,transparent)}
}
§FRM{
:root{accent-color:var(--accent)} input,textarea,select{font:inherit} textarea{field-sizing:content;min-block-size:3lh;max-block-size:12lh} input:user-invalid{border-color:var(--danger)} input:user-invalid+.error{display:block} label:has(+:required)::after{content:" *";color:var(--danger)};
field-sizing:content(Cr123+,FF152,SfTP)⇒min/max;:user-invalid>:invalid(¬load);
mobile:{inputmode(numeric|email|search),autocomplete,enterkeyhint(search|send|next)};form.requestSubmit(btn)(valid+submit+event.submitter);
switch(role="switch"):.switch{appearance:none;inline-size:2.5rem;block-size:1.5rem;border-radius:1lh;position:relative} .switch::before{content:"";position:absolute;inset:2px auto 2px 2px;aspect-ratio:1;border-radius:50%;transition:translate 180ms var(--ease-out)} .switch:checked{background:var(--accent)} .switch:checked::before{translate:1rem 0};
select(Cr135+;fb=native;¬<selectmenu>|¬<selectlist>;<selectedcontent>∈<button>):select,::picker(select){appearance:base-select;field-sizing:content} option:checked{background:var(--accent-soft)} option::checkmark{content:"✓"} select::picker-icon{transition:rotate .2s} select:open::picker-icon{rotate:180deg}
}
§OVR{
dialog(<button commandfor="dlg" command="show-modal">,<dialog id="dlg" aria-labelledby="dlg-title" closedby="any">,<form method="dialog">→close+returnValue;closedby="any"|JS_backdrop;dialog.show()_non-modal;ret_focus;autofocus):
dialog::backdrop{background:oklch(0 0 0/.45);backdrop-filter:blur(4px)} html:has(dialog[open]:modal){overflow:hidden} dialog{transition:opacity .2s var(--ease-out),scale .2s var(--ease-out),display .2s allow-discrete,overlay .2s allow-discrete;opacity:0;scale:.96} dialog[open]{opacity:1;scale:1} @starting-style{dialog[open]{opacity:0;scale:.96}};
popover(Base2024:Cr114,FF125,Sf17;¬modal→<dialog>):popovertarget="menu" popover(=auto)|"manual"(hidePopover())|"hint"(¬closes_auto);popovertargetaction="show|hide|toggle";JS:{showPopover(),hidePopover(),togglePopover(),toggle|beforetoggle};
hover:interestfor="tip"(interest-delay-start/end)=Cr_only⇒also_focus+tap;
anchor(Cr125+,Sf26+;chk_FF;fb=abs_under;a11y:aria-describedby/controls/details):
.trigger{anchor-name:--menu-btn} .menu{position:absolute;position-anchor:--menu-btn;position-area:block-end span-inline-end;min-inline-size:anchor-size(inline);position-try-fallbacks:flip-block,flip-inline} .tooltip{position-area:top;inset-inline-start:calc(anchor(center) - 1rem)};
anchor_rules:position-area=3×3;anchor()_in_inset(math→calc());@position-try --name{…};anchor-scope:--name;popovertarget⇒implicit_anchor;
tooltip:suppl¬inter(else_toggletip_<button>+popover);hover+focus+Esc(WCAG1.4.13);¬title
}
§UI{
accordion:<details name="faq"><summary>…</summary>…</details>(excl_Base2024;anim:::details-content+interpolate-size⇒animation-motion;hidden="until-found"+beforematch∈{Chrm,FF});summary{list-style:none}summary::-webkit-details-marker{display:none};
carousel(Cr135+_::scroll-button/::scroll-marker;mandatory_iff_∀item_fits_else_proximity;scroll-snap-stop:always;¬auto_w/o_pause):
.track{display:grid;grid-auto-flow:column;grid-auto-columns:min(80%,20rem);overflow-x:auto;overscroll-behavior-x:contain;scroll-snap-type:x mandatory;scroll-padding-inline:1rem;scroll-marker-group:after} >*{scroll-snap-align:start} >*::scroll-marker{content:"";inline-size:.5rem;aspect-ratio:1;border-radius:50%} :target-current{background:var(--accent)} ::scroll-button(inline-start|end){content:"←"/"Previous"|"→"/"Next"};
scrollbars(Base_Newly;kills_::-webkit-scrollbar⇒¬use;none_iff_affordance):.scroller{scrollbar-width:thin;scrollbar-color:var(--thumb) transparent;scrollbar-gutter:stable};
loading:skeleton_shimmer(match_dims+radius,aria-busy="true",stop_@prefers-reduced-motion:reduce,reserve_space)
}
§ANTI{
<dialog>_no_showModal()⇒¬backdrop∧¬inert;popover=fixed_top_layer(escapes_overflow∧z-index,¬transform_on_self);
checkbox_appearance:none⇒style{:checked,:indeterminate,:disabled,:focus-visible};¬nest_block+interactive_in_<a>;
scroll-behavior:smooth_in_prefers-reduced-motion:no-preference
}
