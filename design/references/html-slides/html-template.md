@REF:html-template
§ARCH{
  files:single→(presentation.html[inline_CSS/JS]+assets/)⊕multi→([name].html+[name]-assets/);
  fonts:self_hosted_WOFF2(assets/)⇒offline_ok;Fontshare|GoogleFonts⇔user_accepts_net_dep;
  `@font-face`:`font-family:"Display";src:url("assets/display.woff2") format("woff2");font-display:swap`;
  tokens:MUST_use(clamp())∀type/spacing;`:root`={--bg-primary:#0a0f1c;--bg-secondary:#111827;--text-primary:#fff;--text-secondary:#9ca3af;--accent:#00ffcc;--accent-glow:rgba(0,255,204,.3);--font-display:"Clash Display",sans-serif;--font-body:"Satoshi",sans-serif;--title-size:clamp(2rem,6vw,5rem);--subtitle-size:clamp(.875rem,2vw,1.25rem);--body-size:clamp(.75rem,1.2vw,1rem);--slide-padding:clamp(1.5rem,4vw,4rem);--content-gap:clamp(1rem,2vw,2rem);--ease-out-expo:cubic-bezier(.16,1,.3,1);--duration-normal:.6s};
  base_css:`*{margin:0;padding:0;box-sizing:border-box}`+viewport-base.css+`.reveal{opacity:0;transform:translateY(30px);transition:opacity var(--duration-normal) var(--ease-out-expo),transform var(--duration-normal) var(--ease-out-expo)} .slide.visible .reveal{opacity:1;transform:translateY(0)} .reveal:nth-child(1..4){transition-delay:.1s..0.4s}`;
  dom:`<!DOCTYPE html><html lang="en">`→`<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">`→`<div class="progress-bar"></div><nav class="nav-dots"></nav>`→`<section class="slide title-slide"><h1 class="reveal">...</h1><p class="reveal">...</p></section>`→`<section class="slide"><div class="slide-content"><h2 class="reveal">...</h2><p class="reveal">...</p></div></section>`
}
§JS{
  `class SlidePresentation`:init `this.slides=document.querySelectorAll(".slide");this.currentSlide=0;`→call `setupIntersectionObserver()`(.visible on viewport entry),`setupKeyboardNav()`(arrows,Space,PageUp/PageDown),`setupTouchNav()`(touch/swipe),`setupProgressBar()`(scroll progress),`setupNavDots()`(CRITICAL:`this.navDotsContainer.innerHTML=""` first to prevent duplicate dots if outerHTML saved while rendered)+mouse wheel nav;instantiate `new SlidePresentation()`;
  opt_enhancements:{canvas_particles,parallax,tilt_3d,magnetic_btns,counters};
  inline_edit:opt_in_only(¬req⇒emit_∅_edit_HTML/CSS/JS)
}
§EDIT{
  gate:user_requested_inline_edit?true⇒include:skip_all;
  anti:¬CSS(`.edit-hotzone:hover ~ .edit-toggle`)[`pointer-events:none` breaks hover chain before click]⇒MUST_use(JS_hover_400ms_timeout);
  features:{toggle_btn(hidden_default,hotzone|E_key),localStorage_autosave,exportFile};
  html:`<div class="edit-hotzone"></div><button class="edit-toggle" id="editToggle" title="Edit mode (E)">Edit</button>`;
  css:`.edit-hotzone{position:fixed;top:0;left:0;width:80px;height:80px;z-index:10000;cursor:pointer} .edit-toggle{opacity:0;pointer-events:none;transition:opacity .3s ease;z-index:10001} .edit-toggle.show,.edit-toggle.active{opacity:1;pointer-events:auto}`;
  js:
    `#editToggle`.click⊕`.edit-hotzone`.click⇒`editor.toggleEditMode()`;
    `hotzone`.mouseenter⇒`clearTimeout(ht);et.classList.add("show")`;
    `et`.mouseenter⇒`clearTimeout(ht)`;
    (`hotzone`|`et`).mouseleave⇒`ht=setTimeout(()=>{if(!editor.isActive)et.classList.remove("show")},400)`;
    `document`.keydown(e)⇒`(e.key==="e"||e.key==="E")&&!e.target.getAttribute("contenteditable")`⇒`editor.toggleEditMode()`;
  export_critical:strip_edit_state_before_`outerHTML`_else_saved_file_opens_stuck_in_edit_mode;
  ```js
exportFile(){
  const els=[...document.querySelectorAll('[contenteditable]')];
  els.forEach(el=>el.removeAttribute('contenteditable'));
  document.body.classList.remove('edit-active');
  const et=document.getElementById('editToggle'),eb=document.querySelector('.edit-banner');
  et?.classList.remove('active','show');eb?.classList.remove('active','show');
  const html='<!DOCTYPE html>\n'+document.documentElement.outerHTML;
  document.body.classList.add('edit-active');
  els.forEach(el=>el.setAttribute('contenteditable','true'));
  et?.classList.add('active');eb?.classList.add('active');
  const a=document.createElement('a');
  a.href=URL.createObjectURL(new Blob([html],{type:'text/html'}));
  a.download='presentation.html';a.click();URL.revokeObjectURL(a.href);
}
```
}
§IMG{
  gate:no_images⇒skip;dep:`pip install Pillow`(`from PIL import Image,ImageDraw`);
  rules:suffix=`_processed`∧¬overwrite_originals;direct_paths(¬base64);adapt_border/shadow_to_accent;¬repeat_img(except_logo@title+closing);
  ops:square_logo_rounded⇒`crop_circle(in,out)`(center square crop+`L` mask ellipse alpha+save PNG);img>1MB⇒`resize_max(in,out,max_dim=1200)`(`Image.LANCZOS`,quality=85);wrong_aspect⇒`img.crop()`;
  html:`<img src="assets/logo_round.png" alt="Logo" class="slide-image logo"/>` | `<img src="assets/screenshot.png" alt="Screenshot" class="slide-image screenshot"/>`;
  css:`.slide-image{max-width:100%;max-height:min(50vh,400px);object-fit:contain;border-radius:8px} .slide-image.screenshot{border:1px solid rgba(255,255,255,.1);border-radius:12px;box-shadow:0 8px 32px rgba(0,0,0,.3)} .slide-image.logo{max-height:min(30vh,200px)}`;
  placement:title_logo_centered;screenshots_2col_with_text;full_bleed_bg_overlay(sparingly)
}
§QA{comments:explain_section+how_to_modify;a11y:{semantic(<section>,<nav>,<main>),full_kbd,ARIA_labels,prefers-reduced-motion(in_viewport-base.css)}}
