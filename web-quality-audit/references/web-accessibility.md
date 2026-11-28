@REF:web-accessibility
§SCOPE{std:WCAG_2.2_AA(supersedes_2.1)∧ARIA_1.2∧EAA(EN_301_549,enforced_Jun2025)∧ADA_Title_II(WCAG_2.1_AA,2027-2028)∧Sec_508;POUR:{Perceivable:seen|heard,Operable:kbd|input,Understandable:clear|pred,Robust:AT_compat}}
§FIX{
  1_Alt:{info:`alt="desc"`,decor:`alt=""`,logo_lnk:`<a href="/"><img src="..." alt="Name – Home"></a>`,complex:`<figure>`+`<figcaption>`,¬"Image of..."};
  2_Contrast:{norm:≥4.5:1(AA)|≥7:1(AAA),lg(≥18pt/24px∨≥14pt/18.67px_bold):≥3:1(AA)|≥4.5:1(AAA),UI_icons/borders:≥3:1,focus_ring:≥3:1,ex_on_#fff:#949494(3.03:1_fail_norm_AA)|#767676(4.54:1_AA)|#595959(7.0:1_AAA)|#333(12.63:1_AAA)};
  3_Semantic:native(`<button>`,`<a>`,`<h1>`-`<h6>`,`<nav>`,`<main>`,`<section>`,`<article>`,`<aside>`,`<ul>`/`<ol>`/`<li>`,`<table>`)>`div[onclick]`;
  4_Forms:{visible_lbl(`<label for="id">`|wrap `<label>`)∧¬placeholder_only,`aria-label`⇔¬visual_lbl,grp:`<fieldset>`+`<legend>`,err_suggestion(3.3.3),reflow@400%(1.4.10)};
  5_Kbd:{interactive∈Tab,visible_`:focus-visible`,tab_order==visual,¬kbd_trap,div_btn_fallback:`role="button" tabindex="0" onkeydown="if(event.key==='Enter'||event.key===' ')..."`};
  6_Landmarks:native_implicit(`<header>`,`<nav aria-label="...">`,`<main>`(max_1/pg),`<aside aria-label="...">`,`<footer>`)¬redundant_role_attrs;
  7_Modals_Popovers:{native_1st:`<dialog>.showModal()`(built-in_top_layer,backdrop,focus_trap,Esc_close,inert_bg,role=dialog,aria-modal=true)∧Popover_API(`popover="auto"|"manual"`+`popovertarget` for light-dismiss menus/tooltips)∧`inert`_attr_on_bg_containers/drawers;custom_fallback:`role="dialog" aria-modal="true" aria-labelledby`+focus_1st+trap+restore_trigger+Esc};
  8_Skip:1st `<a href="#main" class="skip-link">`→`<main id="main" tabindex="-1">`;CSS:`top:-40px`→`:focus{top:0}`
}
§ARIA{
  states:{aria-checked,aria-disabled,aria-expanded,aria-hidden,aria-pressed,aria-selected};
  props:{aria-label,aria-labelledby,aria-describedby,aria-live,aria-required,aria-invalid};
  live:{polite:`aria-live="polite" aria-atomic="true"`,err:`role="alert" aria-live="assertive"`};
  accordion:`<button aria-expanded="false" aria-controls="panel-1" id="acc-1">`+`<div id="panel-1" role="region" aria-labelledby="acc-1" hidden>`;
  tabs:`role="tablist" aria-label="..."`+`<button role="tab" aria-selected="true|false" aria-controls="panel-1" id="tab-1" [tabindex="-1"]>`+`<div role="tabpanel" id="panel-1" aria-labelledby="tab-1" [hidden]>`;
  rule:native_HTML(`<dialog>`,`[popover]`,`inert`,`<details>`,`<button>`)>ARIA
}
§MED_MOT_LANG{
  video:`<video controls><track kind="captions" src="*.vtt" srclang="en" default><track kind="descriptions" src="*.vtt" srclang="en"></video>`;
  audio:`<audio controls>`+`<details><summary>Transcript</summary>`;
  motion:`@media (prefers-reduced-motion: reduce){*{animation-duration:0.01ms !important;transition-duration:0.01ms !important;}}`;
  lang:`<html lang="en">`+`<span lang="fr">`;consistent_nav;desc_links;robust:{uniq_IDs,valid_nesting(W3C),native>ARIA}
}
§WCAG22{
  2.4.11_FocusNotObscured(AA):sticky_hdr|banner|overlay∉entirely_hide(focus);2.4.12(AAA):no_part_obscured;
  2.4.13_FocusAppearance(AAA):focus_area+≥3:1_contrast_Δ;
  2.5.7_DraggingMovements(AA):∀drag⇒single_ptr_alt(btns,click_move);
  2.5.8_TargetSize(Min,AA):≥24×24px(mobile_rec:iOS_44×44pt,Android_48×48dp);
  3.2.6_ConsistentHelp(A):help_links/chat/contact_in_same_rel_order_across_pages;
  3.3.7_RedundantEntry(A):¬re_ask∈same_process(prefill|select);
  3.3.8_AccessibleAuth(Min,AA):¬cognitive_test_only(allow_paste+pw_mgr+passkeys/OAuth/magic_link);3.3.9(AAA):no_cognitive_test
}
§XPLAT{lbl:Web(`aria-label`/`<label>`)|iOS(`.accessibilityLabel()`)|Android(`contentDescription`);hint:Web(`aria-describedby`)|iOS(`.accessibilityHint()`)|Android(`Modifier.semantics{stateDescription=...}`);role:Web(`role="button"`)|iOS(`.accessibilityAddTraits(.isButton)`)|Android(`Modifier.semantics{role=Role.Button}`);live:Web(`aria-live="polite"`)|iOS(`.accessibilityLiveRegion(.polite)`)|Android(`Modifier.semantics{liveRegion=LiveRegionMode.Polite}`)}
§REACT{
  forms:JSX `htmlFor`∧¬`for`,`<span aria-hidden="true">*</span>`,`required aria-required="true" aria-invalid={!!err} aria-describedby={err?'id-err':undefined} autoComplete="email"`+`{err&&<span id="id-err" role="alert">{err}</span>}`;
  lbl:icon_btn→`aria-label`+`<XIcon aria-hidden="true"/>`,heading→`<section aria-labelledby="id"><h2 id="id">`;
  acc:const `id=useId()`→`aria-expanded={open} aria-controls={id}`+`<div id={id} hidden={!open}>`;
  dropdown:`role="combobox" aria-expanded aria-haspopup="listbox" aria-controls={listId} tabIndex={0}`+`role="option" aria-selected={i===active}`;keys:{ArrowDown:min(i+1,len-1),ArrowUp:max(i-1,0),Enter|' ':open?select:toggle,Escape:close}(preventDefault);
  modal:prefer_native(`<dialog ref={r}>`+`r.current?.showModal()`/`close()`);custom_fallback:save `document.activeElement as HTMLElement`→focus_modal(`tabIndex={-1}`,Esc→close,`inert`_on_bg)→restore_on_close;
  reduced_motion:`export function useReducedMotion():boolean{const[r,setR]=useState(false);useEffect(()=>{const m=window.matchMedia('(prefers-reduced-motion: reduce)');setR(m.matches);const f=(e:MediaQueryListEvent)=>setR(e.matches);m.addEventListener('change',f);return()=>m.removeEventListener('change',f);},[]);return r;}`
}
§ANTI{`<div aria-label="...">`(no_role);`tabIndex>0`;`<button aria-hidden="true">`;`<div role="button">`¬(`tabIndex={0}`∧Enter/Space);skip_headings(`h1`→`h4`);color_only_status;alt="Image of...";blocking_password_paste(fails_3.3.8);sticky_header_covering_focus(fails_2.4.11)}
§TEST{
  cmd:`npx lighthouse https://example.com --only-categories=accessibility` ∧ `npx @axe-core/cli https://example.com --tags wcag2a,wcag2aa,wcag21aa,wcag22aa`;
  playwright:`new AxeBuilder({page}).withTags(['wcag2a','wcag2aa','wcag21aa','wcag22aa']).analyze()`;
  mcp:`lighthouse_audit`+`take_snapshot(verbose:true)`;
  engine:axe-core_4.14+(supports_ElementInternals;requires_explicit_wcag22aa_tag;auto_catches_structural_only⇒manual_req_for_2.4.11,2.5.8,3.3.8);
  manual:{kbd(Tab,Enter,Space,Esc,arrows),SR(NVDA,JAWS,VoiceOver,TalkBack),vis_focus_not_obscured,err_alert,modal/popover_focus+Esc,skip_lnk,200%_zoom+400%_reflow,Win_HC,reduced_motion,JS_off};
  sr_keys:{toggle:VO(Cmd+F5)|NVDA(Ctrl+Alt+N),next:VO+Right|Down,prev:VO+Left|Up,act:VO+Space|Enter,hdg:VO+U+arrows|H/Shift+H,lnk:VO+U|K/Shift+K}
}
§CHK{∀img_alt;contrast_ok(18pt/14pt_bold_rule);semantic+landmarks;vis_lbls;kbd+vis_focus_not_obscured;target≥24×24px;accessible_auth;skip_lnk;native_dialog/popover/inert;media_cap|sub|trans;lang+inline_lang;¬ARIA_misuse;auto_0_crit(axe_wcag22aa,LH13);manual_SR_ok}
§SRC{WCAG22:https://www.w3.org/WAI/WCAG22/quickref/;APG:https://www.w3.org/WAI/ARIA/apg/;axe:https://dequeuniversity.com/rules/axe/;Contrast:Colour_Contrast_Analyser(WebAIM);SR:{NVDA(free),JAWS(comm),VoiceOver(macOS|iOS)}}
§REL{[frontend-development](../../frontend-development/SKILL.md);[web-quality-audit](../SKILL.md);[playwright](../../unit-testing-patterns/references/playwright.md);[ux-research](../../ux-research/SKILL.md);[i18n-localization](../../i18n-localization/SKILL.md)}
