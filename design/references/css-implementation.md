@REF:css-implementation
§PARENT:[design](../SKILL.md)_§25;partial⇒[css/browser-support.md](css/browser-support.md)
§R{
1:native(`<dialog>`,`popover`,`<details name>`,`:has()`,anchor,scroll-anim,view-trans);
2:`@layer reset,base,components,utilities;`,1-class,`:where()`_reset,¬ID,`!important`∈util;
3:Grid_2D,Flex_1D,`gap`¬margin;intrinsic(`repeat(auto-fill,minmax(min(100%,16rem),1fr))`,`clamp()`),CQ;
4:logical;`rem`+`clamp()`,`~65ch`,unitless_lh;`dvh`/`svh`,¬`100vw`;
5:role_tokens,swap_semantic;`oklch()`,rel/`color-mix()`,`color-scheme`+`light-dark()`;
6:4.5:1(3:1_lg/UI);`:focus-visible`∀;target≥24px(44_touch);DOM=visual;
7:anim_`transform`/`opacity`/`translate`/`rotate`/`scale`,150-300ms,`prefers-reduced-motion:no-preference`;`@starting-style`+`allow-discrete`;`@property`_vars;
8:reserve(`aspect-ratio`,`contain-intrinsic-size`);LCP_`fetchpriority="high"`¬lazy;lazy_below;`content-visibility:auto`;
9:self_WOFF2_subset,preload≤2,metric_fallback;
10:`@supports`|fallbacks,¬hide_content;
11:inline_SVG_`currentColor`;`aria-hidden`_deco,`role="img"`+`<title>`_info;
12:¬`innerHTML`_untrusted;`setProperty('--x',v)`;attr_state;
13:`@media(hover:hover)`+focus/tap_equiv
}
§DEC(need→use¬avoid){
card_grid/align→`auto-fill minmax()`/`subgrid`¬bp_cols,JS_eq;
masonry→`grid-lanes`∈`@supports`¬JS;
slot_comp→CQ+`cqi`¬vp_MQ;
full_bleed→named_grid_lines¬`100vw`+neg_m;
parent_child→`:has()`¬JS_cls;
3p/scope→`layer(vendor)`/`@scope`¬spec_war;
state/dyn_txt→`oklch(from ...)`/`color-mix()`/`contrast-color()`¬hex/state,white;
modal/menu/tip→`<dialog>`/`popover`+anchor¬traps,JS_xy;
acc/ta/sel→`<details name>`/`field-sizing:content`/`appearance:base-select`¬ARIA,JS_sz,div_sel;
carousel→scroll_snap+`::scroll-button()`¬JS,autoplay;
anim_auto→`interpolate-size`|grid_`0fr->1fr`¬JS_meas;
scroll/page→`animation-timeline`/VT¬listeners,FLIP;
spring→`linear()`¬JS_phys;
grad_border+rad→`padding-box`/`border-box`¬`border-image`;
bal/opt→`text-wrap:balance`/`text-box:trim-both`¬`<br>`,pad;
stagger→`sibling-index()`(`--i`_fb)¬`:nth-child`;
tokens/css→DTCG→Style_Dictionary;TW_v4,CSS_Mod¬hardcode,rt_CSS-in-JS
}
§TOPICS{[layout.md](css/layout.md);[responsive.md](css/responsive.md);[selectors-cascade.md](css/selectors-cascade.md);[custom-properties-math.md](css/custom-properties-math.md);[color.md](css/color.md);[visual-effects.md](css/visual-effects.md);[typography.md](css/typography.md);[animation-motion.md](css/animation-motion.md);[components-ui.md](css/components-ui.md);[svg.md](css/svg.md);[accessibility.md](css/accessibility.md);[performance.md](css/performance.md);[architecture-tooling.md](css/architecture-tooling.md);[frontend-js.md](css/frontend-js.md);[browser-support.md](css/browser-support.md)(Nov_2026)}
§CHK{fallbacks;kbd+focus;DOM=visual;contrast(lt,dk,HC);red_motion;320px∧200%;¬CLS;LCP¬lazy;tokens;flat_sel}
