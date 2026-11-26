@REF:gsap
§REL{../SKILL.md:parent;immersive-web.md:scroll_story}
§WHEN{scroll(pin,scrub,parallax,horiz),timeline,plugins(Flip,Draggable,SplitText,DrawSVG,MorphSVG,MotionPath,ScrollSmoother;free≥3.13,¬Club),React/Next/Vue/Nuxt/Svelte,FPS}
§REF{
tweens|to/from/fromTo|ease|stagger|defaults|matchMedia→gsap/gsap-core.md;
seq|pos|labels|nested|playback→gsap/gsap-timeline.md;
scroll|trigger|pin|scrub|snap|batch|horiz→gsap/gsap-scrolltrigger.md;
scrollTo|Flip|Draggable|Inertia|Observer|text|SVG|physics|customEase|GSDevTools→gsap/gsap-plugins.md;
clamp|mapRange|normalize|interpolate|random|snap|toArray|wrap|pipe→gsap/gsap-utils.md;
React|Next|useGSAP|refs|gsap.context|cleanup→gsap/gsap-react.md;
Vue|Nuxt|Svelte|SvelteKit|lifecycle|scoped|cleanup→gsap/gsap-frameworks.md;
perf|transforms|no_thrash|will-change|batch→gsap/gsap-performance.md
}
§R{default=Motion(motion/react);GSAP=scrolltelling(¬upstream_rec);¬mix(GSAP,Motion)∈1_tree;isolate∈'use client'+cleanup;scroll∈gsap.matchMedia()((prefers-reduced-motion:no-preference))}
§META{MIT_2026_GreenSock;https://github.com/greensock/gsap-skills}
