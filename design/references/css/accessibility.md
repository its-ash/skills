@REF:accessibility
§USE{HTML/CSS:kbd,SR,zoom,HC,reduced_motion,WCAG_2.2}
§R{
semantic_first(¬ARIA_if_native);
∀int⇒kbd+`:focus-visible`(≥2px,≥3:1_adj),¬`outline:none`_bare;
contrast:4.5:1_norm,3:1_lg(`24px`|`18.66px`_bold)+UI/icons;
target≥`24x24`px(WCAG_2.2_AA_2.5.8),touch_`44x44`;
form_ctrl⇒`<label for>`|wrap_`<label>`|`aria-labelledby`(placeholder≠label);
¬color_alone→text/icon/pattern;
reflow:200%_zoom∧320px_¬x-scroll(WCAG_1.4.10)⇒`rem`,intrinsic,¬fixed_h_txt;
`prefers-reduced-motion`+pause_auto_move;
DOM=visual(`order`/`grid-area`/`row-reverse`_¬fix_focus/SR)
}
§FOCUS{
`:focus-visible{outline:2px solid var(--focus,Highlight);outline-offset:2px}`(Baseline_2022:kbd+text_inputs,¬mouse_btn);
`.card:focus-within{box-shadow:0 0 0 2px var(--focus)}`;
var_bg⇒2-color(`outline`+`box-shadow`);
sticky_hdr(WCAG_2.4.11)⇒`html{scroll-padding-block-start:var(--header-h)}`;
route_Δ|del⇒focus(new_h|next);
`tabindex`:`0`(order),`-1`(JS),¬`>0`;
`reading-flow:flex-visual|grid-rows`+`reading-order`(Chromium_exp)⇒¬rely
}
§HIDE{
∀→`hidden`|`display:none`|`visibility:hidden`;
vis_¬AT→`aria-hidden="true"`(¬focusable);
¬vis_AT→`.sr-only:not(:focus):not(:active){position:absolute;inline-size:1px;block-size:1px;margin:-1px;padding:0;overflow:hidden;clip-path:inset(50%);white-space:nowrap;border:0}`;
CtrlF→`hidden="until-found"`;
vis_¬int→`inert`
}
§SKIP{`<a class="skip-link" href="#main">Skip to content</a>`→`<main id="main" tabindex="-1">`;`.skip-link{position:absolute;inset-inline-start:1rem;translate:0 -200%}.skip-link:focus{translate:0 0}`}
§FORM{`<fieldset>`+`<legend>`;err:`aria-invalid="true"`+`aria-describedby`,focus_1st|summary;`:user-invalid`;`required`+vis_ind(`aria-required`_custom);`type`+`autocomplete`(`email`,`tel`,`one-time-code`,`current-password`,WCAG_1.3.5);¬disable_submit}
§ARIA{
`aria-label`(str),`aria-labelledby`(IDs,>label),`aria-describedby`;
`aria-expanded`(discl),`aria-pressed`(toggle),`aria-current="page"`(nav),`aria-selected`(tab/listbox);`aria-controls`(weak,opt);
live:`role="status"`(polite),`role="alert"`(assertive)⇒preexist_DOM;
`ariaNotify("Saved",{priority:"normal"})`(WAI-ARIA_1.3;FF_150,Chromium)+live_fb;
CSS:`[aria-expanded="true"] .chevron{rotate:180deg}`;
¬dup_role(`<button role="button">`);¬`role="presentation"`_focusable
}
§DLG{`dialog.showModal()`(trap,Esc,inert_bg,return_focus)+`aria-labelledby`;¬`inert`_ancestor;toast:`role="status"`,¬steal_focus,persist|dismiss}
§STRUCT{1_`<main>`,`<header>`,`<nav aria-label="Primary">`,`<footer>`,`<aside>`,label_dups;1_`<h1>`,¬skip_lvl;Safari/VO_`list-style:none`⇒`role="list"`;`<table>`+`<th scope>`+`<caption>`,¬`grid|flex`_on_table;¬`display:contents`_sem/int}
§MEDIA{info→`alt`;deco→`alt=""`;func→action;complex→short_`alt`+full_text;vid→captions;aud→transcript;¬autoplay_sound;¬CSS_bg_content}
§MODES{`forced-colors:active`⇒ctrl_borders,sys_colors,¬`box-shadow`_focus⇒`outline:2px solid transparent`;`prefers-contrast:more`⇒↑border+txt;`color-scheme:light dark`}
§TEXT{¬zoom_lock(`maximum-scale=1`,`user-scalable=no`);WCAG_1.4.12(lh_1.5,para_2em,ls_0.12em,ws_0.16em,¬fixed_h);body_links⇒underline;`user-select:none`_chrome_only}
§CHK{Tab_all(order,vis,¬trap);SR(VO/Safari,NVDA/FF|Chr,JAWS,TalkBack);200%+400%+320px;axe|LH+manual(auto≈1/3);Win_HC+red_motion}
§GOTCHA{`aria-hidden="true"`_w/_focusable⇒ghost_stop;`display:none`/`visibility:hidden`_valid_`aria-labelledby`/`describedby`_target;`pointer-events:none`¬stop_kbd⇒`disabled`/`inert`;placeholder≠contrast+vanishes;hover_only⇒focus+tap}
