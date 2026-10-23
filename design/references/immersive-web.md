> **Parent skill:** [`design`](../SKILL.md). This is a sub-skill; follow `design` for the shared workflow and load this only when the task needs it.

# Immersive Web

Create web experiences that feel like a narrative journey. Combine scroll‑driven animations, parallax depth, sticky sections, and WebGL 3D to turn a page into an interactive story.

## When to use
- Long‑form articles or product pages that benefit from visual storytelling.
- Landing pages that need cinematic impact without sacrificing performance.
- Portfolios that want to showcase work with scroll‑based reveals or 3D product configurators.
- Any site where scroll is the primary navigation cue.

---

## Core Concepts
| Concept | Purpose | Typical Implementation |
|---|---|---|
| **Scroll‑driven animation** | Tie motion to the user’s scroll position. | GSAP ScrollTrigger, Framer Motion, CSS `scroll‑timeline` |
| **Parallax depth** | Create a sense of distance by moving layers at different speeds. | GSAP layer tweens, CSS transforms, custom JavaScript |
| **Sticky sections** | Keep an element visible while the rest of the page scrolls. | CSS `position: sticky`, GSAP pinning |
| **Scroll snapping / horizontal scroll** | Guide the user through discrete panels. | CSS `scroll-snap-type`, GSAP horizontal panels |
| **3D integration** | Add interactive models or scenes that react to scroll. | Three.js, React Three Fiber, GSAP + Three.js |
| **Performance & accessibility** | Ensure smooth frames and keyboard / screen‑reader support. | Reduce asset size, use `prefers-reduced-motion`, provide fallbacks |

---

## Tool Stack
| Category | Recommended Options | Notes |
|---|---|---|
| **Animation library** | **GSAP ScrollTrigger** – powerful, medium learning curve. <br> **Framer Motion** – low barrier for React projects. <br> **CSS `scroll‑timeline`** – native, low learning curve for simple reveals. | Choose based on project framework and animation complexity. |
| **Smooth scroll / parallax** | **Locomotive Scroll** – smooth scroll + built‑in parallax. <br> **Lenis** – lightweight smooth scroll only. | Add only if native scroll is insufficient. |
| **3D rendering** | **React Three Fiber** – React‑friendly wrapper around Three.js. <br> **Three.js (vanilla)** – maximum control, higher learning curve. <br> **Spline** – rapid prototyping for designers. | Prefer R3F for React sites; fallback to Three.js for non‑React. |
| **Model optimization** | `@gltf-transform/cli` – Draco compression, texture WebP conversion. |
| **Loading UI** | `@react-three/drei` `useProgress` + `Html` for 3D loaders. |

---

## Implementation Patterns
### 1. Basic Scroll Animation (GSAP)
```javascript
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

gsap.to('.element', {
  scrollTrigger: {
    trigger: '.element',
    start: 'top center',
    end: 'bottom center',
    scrub: true,          // ties animation to scroll position
  },
  y: -100,
  opacity: 1,
});
```
### 2. React Scroll Animation (Framer Motion)
```tsx
import { motion, useScroll, useTransform } from "framer-motion";

export function ParallaxSection() {
  const { scrollYProgress } = useScroll();
  const y = useTransform(scrollYProgress, [0, 1], [0, -200]);
  return (
    <motion.div style={{ y }}>
      Content moves with scroll
    </motion.div>
  );
}
```
### 3. Native CSS Reveal (2024+)
```css
@keyframes reveal {
  from { opacity: 0; transform: translateY(50px); }
  to   { opacity: 1; transform: translateY(0); }
}

.animate-on-scroll {
  animation: reveal linear;
  animation-timeline: view();
  animation-range: entry 0% cover 40%;
}
```
### 4. Parallax Layer Speeds
```javascript
// GSAP example for two layers
gsap.to('.background', { scrollTrigger:{ scrub:true }, y: '-20%' }); // slower
gsap.to('.foreground', { scrollTrigger:{ scrub:true }, y: '-50%' }); // faster
```
### 5. Sticky Section (CSS)
```css
.sticky-container { height: 300vh; }
.sticky-element {
  position: sticky;
  top: 0;
  height: 100vh;
}
```
### 6. Sticky Section (GSAP Pin)
```javascript
gsap.to('.content', {
  scrollTrigger: {
    trigger: '.section',
    pin: true,
    start: 'top top',
    end: '+=1000',
    scrub: true,
  },
  x: '-100vw',
});
```
### 7. Horizontal Scroll Panels (GSAP)
```javascript
const panels = gsap.utils.toArray('.panel');

gsap.to(panels, {
  xPercent: -100 * (panels.length - 1),
  ease: 'none',
  scrollTrigger: {
    trigger: '.horizontal-container',
    pin: true,
    scrub: 1,
    end: () => '+=' + document.querySelector('.horizontal-container').offsetWidth,
  },
});
```
### 8. 3D Scene with Scroll (React Three Fiber)
```tsx
import { Canvas } from '@react-three/fiber';
import { ScrollControls, useScroll } from '@react-three/drei';
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';

function RotatingModel() {
  const scroll = useScroll();
  const ref = useRef();
  useFrame(() => {
    if (ref.current) {
      ref.current.rotation.y = scroll.offset * Math.PI * 2;
    }
  });
  return <mesh ref={ref}>/* geometry */</mesh>;
}

export default function Scene() {
  return (
    <Canvas>
      <ScrollControls pages={3}>
        <RotatingModel />
      </ScrollControls>
    </Canvas>
  );
}
```
### 9. GSAP + Three.js Camera Move
```javascript
import gsap from 'gsap';
import ScrollTrigger from 'gsap/ScrollTrigger';
import * as THREE from 'three';

gsap.to(camera.position, {
  scrollTrigger: {
    trigger: '.section',
    scrub: true,
  },
  z: 5,
  y: 2,
});
```
### 10. 3D Model Optimization Pipeline
1. Model in Blender (or similar).<br>
2. Reduce polygon count (< 100 k for web).<br>
3. Bake textures into a single atlas.
4. Export as **GLB/GLTF** (smallest size).
5. Compress with `gltf-transform`:
```bash
npm install -g @gltf-transform/cli

gltf-transform optimize input.glb output.glb \
  --compress draco \
  --texture-compress webp
```
6. Keep final file < 5 MB (ideal). Use a loading overlay with `useProgress`.

---

## Performance & Accessibility Guidelines
- **Prefer native CSS** where possible; it runs on the compositor and avoids JavaScript jank.
- **Use `scrub: true`** instead of fixed‑duration tweens to keep scroll speed natural.
- **Limit simultaneous animations** to 2‑3 major effects per viewport.
- **Test on low‑end mobile**: reduce parallax speed, disable 3D, or serve static images.
- **Respect `prefers-reduced-motion`**: provide a fallback that simply appears without animation.
- **Provide keyboard focus** for interactive elements; ensure sticky sections do not trap focus.
- **Add ARIA live regions** for loading progress of 3D assets.
- **Avoid scroll hijacking** – never block the native scroll wheel or touch gestures.

---

## Anti‑Patterns & Sharp Edges
| Issue | Why it hurts | Remedy |
|---|---|---|
| **Scroll hijacking** | Breaks back‑button, harms accessibility. | Keep native scroll; use `scrub` instead of forced jumps. |
| **Animation overload** | Causes jank, distracts from content. | Animate only key moments; keep total animation time < 2 s per view. |
| **Desktop‑only 3D** | Mobile users lose experience; high battery use. | Detect device capability; serve lower‑poly models or static images on mobile. |
| **Missing loading state** | Users think the page is broken. | Show a progress bar or spinner until the 3D scene is ready. |
| **Critical content hidden** | Users may miss information. | Ensure all text/content is reachable without scrolling past an animation. |
| **Heavy assets** | Increases load time, hurts SEO. | Compress models, lazy‑load off‑screen sections, use `rel=preload` for critical assets. |

---

## Checklist
- [ ] Define story beats (hook, context, journey, climax, resolution).<br>
- [ ] Choose animation library that matches the tech stack.
- [ ] Map parallax layers and assign speed ratios.
- [ ] Decide if any section needs to be sticky or pinned.
- [ ] If 3D is required, pick R3F, Three.js, or Spline.
- [ ] Optimize 3D assets (poly count, Draco, WebP).
- [ ] Implement a loading UI for heavy assets.
- [ ] Add `prefers-reduced-motion` media query fallback.
- [ ] Test on at least one low‑end mobile device.
- [ ] Verify keyboard navigation and screen‑reader announcements.
- [ ] Measure frame rate; aim for ≥ 55 fps on target devices.

---

## Related Skills
- `3d-web-experience`
- `scroll-experience`
- `interactive-portfolio`
- `frontend`
- `landing-page-design`

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`web-accessibility`](../../web-quality-audit/references/web-accessibility.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`design`](../SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
