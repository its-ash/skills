@REF:color
§R{
palettes:oklch()(perceptual_L⇒even_scales/hover);derive:rel_color|color-mix()∧¬handpick_hex;
tokens:role(--color-surface,--color-text,--color-accent)→scale(--blue-500);
root:color-scheme:light dark⇒dark_UI/scrollbars∧light-dark();
no_flash:<head>_JS|SSR_cls;
WCAG_AA:body≥4.5:1,large|UI≥3:1;wide_gamut(display-p3|hi-C_OKLCH):sRGB_fb|gamut_map
}
§SPC{
Base2023:{oklch,oklab,lab,lch,color()};
oklch(L C H/A):L∈[0,1]|%,C~[0,0.37],H=deg(best_palettes);
oklab():interp(grads/mix;¬gray_drift);
hsl():non-percept_L(50%yellow≫50%blue)⇒¬a11y_scales;
color(display-p3 r g b):wide_gamut;MQ:@media (color-gamut:p3)
}
§REL{
oklch(from var(--brand) calc(l - .08) c h)[hover],l c h/15%[soft],l c calc(h + 180)[comp],.98 .02 h[on-brand];
channels:{rgb():r g b,oklch():l c h,alpha};Base2024(FF128,Sf18)
}
§MIX{
color-mix(in oklab,var(--accent),black 15%)|in oklch,var(--accent) 20%,white|in srgb,var(--accent) 40%,transparent;
missing_%→100%;sum<100%⇒prop_alpha;polar:in oklch longer hue;Base2023
}
§THM{
:root{color-scheme:light dark;--surface:light-dark(oklch(99% 0 0),oklch(18% .01 260))} :root[data-theme="light|dark"]{color-scheme:light|dark};
light-dark():Base2024;color_only(img:Cr148,FF150);sys+localStorage|cookie;
sys:{Canvas,CanvasText,LinkText,ButtonFace,AccentColor}⇒color-scheme∧forced-colors;
dark:¬invert;↓C,↑elev_L,¬#000/#fff;
chrome:<meta name="theme-color" content="…" media="(prefers-color-scheme:dark)">;
img:<picture><source srcset="dark.png" media="(prefers-color-scheme:dark)"><img …></picture>;
SVG_fav:@media (prefers-color-scheme:dark)∈<style>
}
§CTR{
contrast-color(var(--bg))→b|w(Base:FF146,Cr147,Sf26;test_mid);
OKLCH_fb:color:oklch(from var(--bg) clamp(0,(l - .62)*-infinity,1) 0 0)(~0.6-0.7L);
MQ:{prefers-contrast:more⇒strong_border/txt,forced-colors:active⇒sys+border}
}
§ANIM{colors:native;var⇒@property{syntax:"<color>"};grads:¬direct⇒@property_stops/pos;interp:linear-gradient(in oklch,blue,yellow)}
§FONT{COLRv1:font-palette:dark|@font-palette-values --brand{font-family:…;override-colors:0 var(--accent),1 white}h1{font-palette:--brand}}
§ANTI{hi-C_OKLCH>sRGB⇒gamut-map→chk_sRGB;currentColor:use-time;opacity:fades_children⇒alpha_bg;transparent_grad:premult_alpha_safe(old→#0000);color-mix()_%_var:needs_<percentage>(unitless_fails)}
