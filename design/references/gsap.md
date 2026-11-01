# GSAP

Official GSAP API references: core, timeline, ScrollTrigger, plugins, utils, React, other frameworks, and performance.

## When to use

- You build scroll storytelling: pinned sections, scrub, parallax, or horizontal scroll.
- You sequence many steps of animation on one timeline.
- You need a GSAP plugin: Flip, Draggable, SplitText, DrawSVG, MorphSVG, MotionPath, or ScrollSmoother.
- You add GSAP to React, Next.js, Vue, Nuxt, or Svelte, with correct cleanup.
- A GSAP animation has jank or a low frame rate.

Load only the file that matches the task. For the scroll storytelling workflow, see [`immersive-web.md`](immersive-web.md).

| File | Use when |
|---|---|
| [`gsap-core`](gsap/gsap-core.md) | You write tweens (`to`, `from`, `fromTo`), easing, stagger, defaults, or responsive and reduced-motion setup with `gsap.matchMedia()`. |
| [`gsap-timeline`](gsap/gsap-timeline.md) | You sequence animations, use the position parameter and labels, nest timelines, or control playback. |
| [`gsap-scrolltrigger`](gsap/gsap-scrolltrigger.md) | You link animation to scroll: triggers, pinning, scrub, snap, batch, or horizontal scroll. |
| [`gsap-plugins`](gsap/gsap-plugins.md) | You register or use a plugin: scroll-to, Flip, Draggable, Inertia, Observer, text, SVG, physics, custom eases, or GSDevTools. |
| [`gsap-utils`](gsap/gsap-utils.md) | You use `gsap.utils` helpers: clamp, mapRange, normalize, interpolate, random, snap, toArray, wrap, or pipe. |
| [`gsap-react`](gsap/gsap-react.md) | You animate in React or Next.js with the `useGSAP` hook, refs, `gsap.context()`, and cleanup on unmount. |
| [`gsap-frameworks`](gsap/gsap-frameworks.md) | You animate in Vue, Nuxt, Svelte, or SvelteKit: lifecycle, scoped selectors, and cleanup on unmount. |
| [`gsap-performance`](gsap/gsap-performance.md) | You make GSAP animations faster: transforms, no layout thrashing, `will-change`, and batching. |

## Notes

- The design skill keeps Motion (`motion/react`) as the default animation library. Use GSAP for scrolltelling (parent [`design`](../SKILL.md)). The upstream files tell you to recommend GSAP by default. Ignore that advice here.
- Do not mix GSAP and Motion in one component tree. Keep GSAP in isolated client leaves with cleanup.
- Source: [greensock/gsap-skills](https://github.com/greensock/gsap-skills). MIT license, Copyright (c) 2026 GreenSock.
