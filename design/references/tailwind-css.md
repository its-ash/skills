@REF:tailwind-css
§CFG{TW_v4.3+;src:[design](../SKILL.md);use:{DS/lib_v4,@theme,@container,light-dark()+color-scheme,v3(tailwind.config.js)→v4};arch:{CSS-first(@theme,¬tailwind.config.js),Oxide(Rust,~10x,auto_content),light-dark()(¬dark:_sprawl),nesting+@container(0_plugins)}}

§PAT{THEME
  @theme⇒auto_utils(bg-canvas,bg-surface,text-foreground,border-border-subtle,bg-accent,rounded-card);use_direct(¬bg-[var(--color-accent)]);
  rules:{tonal_elev,¬#000/#fff;1_accent(sat<80%);1_concentric_r(card=inner+p-1/p-2);sans+mono(¬def_Inter)};
  dark::root{color-scheme:light dark}+light-dark();toggle⇒document.documentElement.dataset.theme='light'|'dark';¬bg-white dark:bg-zinc-900...⇒bg-surface text-foreground border-border-subtle
```css
@import "tailwindcss";
:root{color-scheme:light dark}:root[data-theme="light"]{color-scheme:light}:root[data-theme="dark"]{color-scheme:dark}
@theme{
  --color-canvas:light-dark(oklch(98.5% 0.004 250),oklch(13.5% 0.01 250));
  --color-surface:light-dark(oklch(99.5% 0.002 250),oklch(17.5% 0.01 250));
  --color-surface-muted:light-dark(oklch(95.5% 0.006 250),oklch(21.5% 0.012 250));
  --color-surface-elevated:light-dark(oklch(100% 0 0 / 0.96),oklch(23.5% 0.012 250));
  --color-foreground:light-dark(oklch(18% 0.015 250),oklch(94% 0.006 250));
  --color-muted-foreground:light-dark(oklch(46% 0.015 250),oklch(68% 0.01 250));
  --color-border-subtle:light-dark(oklch(18% 0.015 250 / 0.09),oklch(94% 0.006 250 / 0.1));
  --color-border-strong:light-dark(oklch(18% 0.015 250 / 0.18),oklch(94% 0.006 250 / 0.2));
  --color-accent:light-dark(oklch(55% 0.18 250),oklch(68% 0.16 250));
  --color-accent-foreground:oklch(98% 0.005 250);
  --color-accent-soft:color-mix(in oklch,var(--color-accent) 12%,transparent);
  --color-success:light-dark(oklch(54% 0.15 155),oklch(70% 0.14 155));
  --color-danger:light-dark(oklch(56% 0.19 25),oklch(68% 0.17 25));
  --radius-control:0.5rem;--radius-track:0.75rem;--radius-card:1rem;
  --font-sans:"Geist",system-ui,sans-serif;--font-mono:"JetBrains Mono",ui-monospace,monospace;
  --ease-out-expo:cubic-bezier(0.23,1,0.32,1);
}
```
}

§PAT{COMPONENTS
  tabs(filled,¬underline):div[role=tablist].inline-flex.items-center.gap-1.rounded-track.bg-surface-muted.p-1.border.border-border-subtle>act:button[role=tab][aria-selected=true].rounded-control.bg-surface.px-3.5.py-1.5.text-sm.font-medium.text-foreground.shadow-xs.transition-[background-color,color,box-shadow].duration-150|inact:text-muted-foreground.hover:text-foreground.transition-colors.duration-150;
  card(tonal,¬1-side_border,¬nested):article.rounded-card.bg-surface.border.border-border-subtle.p-5.shadow-xs+badge:rounded-full.bg-accent-soft.px-2.5.py-0.5.text-xs.font-medium.text-accent+kpi:text-2xl.font-semibold.tracking-tight.tabular-nums.text-foreground;
  hdr(full-w_sq):header.sticky.top-0.z-50.w-full.rounded-none.border-b.border-border-subtle.bg-surface/85.backdrop-blur-md>div.mx-auto.flex.h-16.max-w-7xl.items-center.justify-between.px-4.sm:px-6;
  cq(comp;vp:sm/md/lg_page):@container(∨@container/card)→@sm:/@md:/@lg:(flex flex-col gap-4 @md:flex-row @md:items-center,img:aspect-video w-full rounded-control object-cover @md:w-48,h:text-balance,p:text-pretty)
}

§R{LAYOUT_MOTION_ANTI
  bp(mob-1st):sm:640px,md:768px,lg:1024px,xl:1280px,2xl:1536px;
  layout:gap-*(¬space-[xy]-*);size-*(¬w-* h-*);min-h-dvh(¬h-screen);grid:grid-cols-[repeat(auto-fill,minmax(min(100%,18rem),1fr))] gap-4;tabular-nums;
  motion:¬transition-all⇒transition-[transform,background-color,box-shadow] duration-150;active:scale-[0.98];motion-safe:/motion-reduce:transition-opacity motion-reduce:transform-none;¬animate-bounce/animate-ping_chrome/dots⇒skeletons;
  anti:¬{dark:_sprawl,1-side_border(border-[lt]-4),underline_tab(border-b-2 border-primary),raw_pal(bg-blue-500,text-gray-600),dyn_cls(bg-${color}),heavy_@apply,tailwind.config.js}
}
