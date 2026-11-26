@REF:svg
§R{
keep viewBox;omit w/h or override in CSS;
SVGO 4(keep viewBox,CSS/JS IDs);sets⇒Lucide|Phosphor;
reuse⇒<symbol>+<use href="#id">(¬xlink:href)
}
§D:Embed{
inline<svg>:CSS=1,cache=0,JS=1⇒styled/interactive/charts;
<img>|CSS_bg:CSS=0,cache=1,JS=0⇒static(0_DOM/scripts/ext_res;own <style> MQ);
<use href="sprite.svg#id">:CSS=inherited,cache=1,JS=0⇒icon_sys(same-origin);
CSS mask:url(i.svg)+bg:currentColor:CSS=color_only,cache=1,JS=0⇒mono_icons;
<object>:CSS=0(own_doc),cache=1,JS=1⇒rare_legacy
}
§PAT:Icons_CSS{
<svg hidden><symbol id="i" viewBox="0 0 24 24"><path/></symbol></svg><svg class="icon" aria-hidden="true" focusable="false"><use href="#i"/></svg>;
.icon{inline-size:1em;block-size:1em;fill:none;stroke:currentColor;stroke-width:2;vertical-align:-.125em}
<use>=closed_shadow→inherited(fill,stroke,color)+--*(fill:var(--icon-accent,currentColor));
cascade:presentation_attr<CSS_rule<inline style="";
CSS_geom:cx,cy,r,rx,ry,x,y,width,height,d:path("…")(Chromium,FF);
transform-box:fill-box;transform-origin:center;vector-effect:non-scaling-stroke;paint-order:stroke
}
§PAT:Stroke_Mask_Filter{
<path class="draw" pathLength="1"/>+.draw{stroke-dasharray:1;stroke-dashoffset:1;animation:d 2s ease forwards}@keyframes d{to{stroke-dashoffset:0}};
pathLength="1" normalizes(¬JS);stroke-linecap/linejoin:round;stroke-miterlimit;odd dasharray→repeats;
<clipPath clipPathUnits="objectBoundingBox">(0-1)→clip-path:url(#c);<mask>⇒luminance(W=show,B=hide,gray=part);
<pattern>(page_bg⇒CSS_gradient|data_URI lighter);data_URI⇒%23(#),single_quotes:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'…");
filters(same-doc filter:url(#id),tight x,y,w,h):
grain:feTurbulence(fractalNoise,baseFrequency=".8",numOctaves=3)+feColorMatrix(saturate,0);
goo:feGaussianBlur(stdDeviation=8)+feColorMatrix("1 0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 20 -8");
primitives:feTurbulence,feDisplacementMap,feMorphology,feComposite,feDropShadow
}
§PAT:Anim_A11y{
CSS_anim(transform,opacity,fill,stroke,stroke-dashoffset,CSS_geom)>SMIL(<animate>,<animateTransform>,<animateMotion>;∀modern+<img>,older `d` morph);
morph(≠pts)⇒GSAP_MorphSVG|flubber(CSS d needs matching cmds);
decorative⇒aria-hidden="true" focusable="false";meaningful⇒<svg role="img" aria-labelledby="t d"><title id="t"/><desc id="d"/></svg>|aria-label;
interactive⇒<a href>|overlay <button>,¬bare <path> click;icon_btn⇒aria-label on <button>,hide SVG;forced-colors⇒currentColor|system_colors
}
§ANTI{
∅viewBox⇒¬scale(w/h crops);inline SVG=display:inline(gap)→block|vertical-align:middle;
dup IDs collide→unique_per_instance;child fill blocks inherited fill→remove|currentColor;
fetch-inline cross-origin⇒CORS+cache
}
