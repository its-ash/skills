# Motion for React

Code patterns for `motion/react` in React and Next.js: shared tokens, reduced motion, SSR safety, UI patterns (presence, stagger, modal, toast, page, scroll, layout), and advanced patterns (drag, gestures, text, SVG, `useAnimate`, loaders). The parent [`design`](../SKILL.md) §5-§9 decides **if** and **how** to animate; this file shows **how to code it**. When a value here is different from the parent, the parent value wins.

## When to use

- You start an animated React component and need shared tokens and spring presets.
- You add `prefers-reduced-motion` support or fix hydration mismatches from animation initial states.
- You animate a button, modal, toast, list, page transition, scroll reveal, accordion, or shared element.
- You build drag-to-dismiss sheets, swipe gestures, reorderable lists, or long press.
- You animate text, counters, SVG paths, progress rings, skeletons, or loading buttons.
- You sequence multi-step animations with `useAnimate`.

Not covered: CSS-only animation (parent §5.E, `references/css/animation-motion.md`), GSAP/Three.js ([immersive-web.md](immersive-web.md)), video scenes ([motion-canvas.md](motion-canvas.md)).

## Rules

1. **Import from `motion/react` only.** Never import from `framer-motion`, and never mix the two in one tree.
2. **`"use client"`** on every file that imports from `motion/react`. Keep motion in client leaves (parent §3).
3. **`initial` must match the server output.** If the server renders `opacity: 1`, the first client render must also be `opacity: 1`.
4. **Reduced motion overrides everything.** When `useReducedMotion()` is `true`, remove transforms and keep a short opacity cross-fade (<= 0.2s), not zero motion (parent §9).
5. **Animate only `transform` and `opacity`** (+ `clip-path`, `pathLength`). Never `width`, `height`, `top`, `left`, `margin`, `padding`.
6. **Durations, easings, and springs come from the token file.** No inline numbers in components.
7. **Never read `window` or `navigator` at module level.** Guard with `typeof window !== "undefined"`.
8. **Every `AnimatePresence` child has a `key` and an `exit`.** Without them, exit animations do not run.
9. **Infinite animations pause when `document.visibilityState === "hidden"`.**
10. **Every listener and animation control has cleanup** in the `useEffect` return.
11. **Never use `useState` for continuous input.** Use `useMotionValue`, `useTransform`, `useScroll`, `useSpring` (parent §3, §12).

## Tokens

One shared file. The values follow parent §5.C, §5.D, §6.B, and §7.

```ts
// lib/motion-tokens.ts
export const motionTokens = {
  duration: {
    instant: 0.1,  // tooltip, focus ring, badge
    fast: 0.16,    // press, icon swap, chip toggle
    normal: 0.25,  // dropdown, card expand, element enter
    slow: 0.4,     // modal, drawer, page element
    story: 0.8,    // hero or storytelling only, rare (parent §5.A)
  },
  easing: {
    out: [0.23, 1, 0.32, 1],       // enter / exit
    inOut: [0.77, 0, 0.175, 1],    // on-screen movement
    drawer: [0.32, 0.72, 0, 1],
    linear: [0, 0, 1, 1],          // constant motion (shimmer, progress)
  },
  distance: { xs: 4, sm: 8, md: 16, lg: 24, xl: 48 },
  scale: {
    enter: 0.95,   // start of enter, never 0
    press: 0.97,
    subtle: 0.98,
    lift: 1.02,    // drag lift only
  },
  stagger: { tight: 0.03, normal: 0.05, loose: 0.08 },  // 30-80ms
} as const

export const springs = {
  ui: { type: "spring", bounce: 0, duration: 0.25 },       // default UI
  move: { type: "spring", bounce: 0, duration: 0.4 },      // panels, cards, modals
  instant: { type: "spring", bounce: 0, duration: 0.15 },  // tooltips, popovers
  drawer: { type: "spring", bounce: 0, duration: 0.3 },
  release: { type: "spring", bounce: 0.2, duration: 0.4 }, // only after momentum gestures (flick, drag release)
} as const
```

| Duration | Use when |
| --- | --- |
| `instant` | Tooltip show/hide, focus ring, badge update |
| `fast` | Button feedback, icon swap, chip toggle |
| `normal` | Dropdown, card expand, element enter |
| `slow` | Modal, drawer, page transition |
| `story` | Hero entrance or deliberate storytelling. Use rarely. |

| Spring | Use when |
| --- | --- |
| `ui` | Buttons, chips, nav items |
| `move` | Cards, modals, panels |
| `instant` | Tooltips, popovers, dropdowns |
| `drawer` | Sheets and drawers |
| `release` | Drag release and flick. Not for state changes. |

## Runtime gate

```ts
// lib/motion-config.ts
export const motionConfig = {
  isLowEnd: () => typeof navigator !== "undefined" && navigator.hardwareConcurrency <= 4,
  prefersReduced: () =>
    typeof window !== "undefined" && window.matchMedia("(prefers-reduced-motion: reduce)").matches,
  shouldAnimate({ essential = false } = {}) {
    if (this.prefersReduced()) return false
    if (!essential && this.isLowEnd()) return false
    return true
  },
}
```

Do not animate when:
- the user prefers reduced motion (use the cross-fade fallback),
- the device is low-end and the animation is not essential,
- the element never enters the viewport,
- you cannot name the purpose of the animation (parent §5.B).

Priority: reduced motion > low-end device > design preference. Motion must degrade without layout shift.

## Reduced motion hook

```tsx
// hooks/use-safe-motion.ts
"use client"
import { useReducedMotion } from "motion/react"

export function useSafeMotion(distance = 16) {
  const reduce = useReducedMotion()
  return {
    initial: { opacity: 0, y: reduce ? 0 : distance },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: reduce ? 0 : -distance },
  }
}
```

```css
@media (prefers-reduced-motion: reduce) {
  .motion-safe-transition { transition: opacity 200ms; }
  .motion-reduce-transform { transform: none; }
}
```

## SSR and hydration

```tsx
// Wrong: server renders opacity 1, client initial is 0 -> hydration mismatch
<motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} />

// Correct: start at the server value until mount
"use client"
const [mounted, setMounted] = useState(false)
useEffect(() => setMounted(true), [])
<motion.div initial={{ opacity: mounted ? 0 : 1 }} animate={{ opacity: 1 }} />
```

Motion values (`useMotionValue`, `useSpring`) are SSR-safe.

## UI patterns

### Pattern choice

| Situation | Pattern |
| --- | --- |
| Element shows / hides | `AnimatePresence` |
| List items enter in sequence | Stagger variants |
| Route change | Page transition wrapper (or View Transitions, parent §15) |
| Element changes size in place | `layout` prop |
| Same element moves between contexts | `layoutId` |
| Element enters when scrolled into view | `whileInView` + `viewport={{ once: true }}` |
| Value tied to scroll position | `useScroll` + `useTransform` |

| `AnimatePresence` mode | Use when |
| --- | --- |
| `wait` | Page transitions, content swaps (one at a time) |
| `sync` | Stacked notifications (overlap is OK) |
| `popLayout` | Items removed from a list that reflows |

- `layout` animates the size/position change of an element in place. `layoutId` links two elements and animates between them.
- Use `layout="position"` on text inside an expanding container so text reflow does not animate.
- Do not put `layout` on subtrees with more than about 5 children or deep DOM. Use explicit `x`/`y` transforms.
- Do not put `layout` on static content (parent §12).

### Button feedback

Hover only on fine pointers (parent §6.A). Press uses the parent press scale.

```tsx
"use client"
import { motion } from "motion/react"
import { motionTokens, springs } from "@/lib/motion-tokens"

<motion.button whileTap={{ scale: motionTokens.scale.press }} transition={springs.ui} />
```

### Stagger list

```tsx
const container = {
  hidden: {},
  visible: { transition: { staggerChildren: motionTokens.stagger.normal } },
}
const item = {
  hidden: { opacity: 0, y: motionTokens.distance.md },
  visible: { opacity: 1, y: 0, transition: springs.move },
}

<motion.ul variants={container} initial="hidden" animate="visible">
  {items.map((i) => <motion.li key={i.id} variants={item} />)}
</motion.ul>
```

Stagger must not block input.

### Modal

Use Radix Dialog, `<dialog>`, or a focus-trap library for focus trap, Escape close, scroll lock, `role="dialog"`, and `aria-modal="true"`. Motion only animates it.

```tsx
"use client"
import { motion } from "motion/react"
import { motionTokens, springs } from "@/lib/motion-tokens"

// <AnimatePresence>{open && <Modal key="modal" onClose={close} />}</AnimatePresence>
export function Modal({ onClose }: { onClose: () => void }) {
  return (
    <>
      <motion.div
        className="fixed inset-0 bg-black/50"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0, transition: { duration: motionTokens.duration.fast } }}
        onClick={onClose}
      />
      <motion.div
        role="dialog"
        aria-modal="true"
        className="fixed inset-x-4 top-1/2 -translate-y-1/2 rounded-xl bg-white p-6"
        initial={{ opacity: 0, scale: motionTokens.scale.enter, y: motionTokens.distance.sm }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: motionTokens.scale.enter, transition: { duration: motionTokens.duration.fast } }}
        transition={springs.move}
      />
    </>
  )
}
```

Exit is faster than enter (parent §6.A).

### Toast stack

```tsx
<AnimatePresence mode="sync">
  {toasts.map((t) => (
    <motion.div
      key={t.id}
      layout
      initial={{ opacity: 0, x: motionTokens.distance.xl, scale: motionTokens.scale.subtle }}
      animate={{ opacity: 1, x: 0, scale: 1 }}
      exit={{ opacity: 0, x: motionTokens.distance.xl, scale: motionTokens.scale.subtle }}
      transition={springs.ui}
    />
  ))}
</AnimatePresence>
```

For production toasts, prefer `sonner` (parent §13).

### Page transition (Next.js App Router)

```tsx
// components/page-transition.tsx
"use client"
import { motion, AnimatePresence } from "motion/react"
import { usePathname } from "next/navigation"
import { motionTokens } from "@/lib/motion-tokens"

const variants = {
  initial: { opacity: 0, y: motionTokens.distance.sm },
  enter: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -motionTokens.distance.sm },
}

export function PageTransition({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={pathname}
        variants={variants}
        initial="initial"
        animate="enter"
        exit="exit"
        transition={{ duration: motionTokens.duration.normal, ease: motionTokens.easing.out }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  )
}
```

### Scroll reveal and progress

```tsx
<motion.div
  initial={{ opacity: 0, y: motionTokens.distance.lg }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-80px" }}
  transition={{ duration: motionTokens.duration.slow, ease: motionTokens.easing.out }}
/>
```

```tsx
"use client"
import { motion, useScroll } from "motion/react"

export function ScrollProgress() {
  const { scrollYProgress } = useScroll()
  return (
    <motion.div
      className="fixed top-0 left-0 h-1 w-full origin-left bg-[var(--accent)]"
      style={{ scaleX: scrollYProgress }}
    />
  )
}
```

Use `viewport={{ once: true }}`. Repeated entrances on scroll-out distract.

### Expanding card and shared element

```tsx
export function ExpandingCard({ title, body }: { title: string; body: string }) {
  const [expanded, setExpanded] = useState(false)
  return (
    <motion.button layout onClick={() => setExpanded((v) => !v)} className="p-6 text-left" aria-expanded={expanded}>
      <motion.h2 layout="position" className="font-semibold">{title}</motion.h2>
      <AnimatePresence>
        {expanded && (
          <motion.p key="body" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
            transition={{ duration: motionTokens.duration.fast }}>
            {body}
          </motion.p>
        )}
      </AnimatePresence>
    </motion.button>
  )
}

// Shared element: same layoutId in both contexts
<motion.img layoutId="hero-image" src={src} className="h-16 w-16 rounded" />
<motion.img layoutId="hero-image" src={src} className="w-full rounded-xl" />
```

### Accordion

Do not animate `height` and do not collapse with `scaleY: 0`. Use the CSS grid `0fr -> 1fr` method (parent §25.C) or `<details name>`:

```tsx
<div
  className="grid transition-[grid-template-rows] duration-300 ease-[cubic-bezier(0.23,1,0.32,1)]"
  style={{ gridTemplateRows: open ? "1fr" : "0fr" }}
>
  <div className="overflow-hidden">{children}</div>
</div>
```

## Advanced patterns

### API choice

| Scenario | API |
| --- | --- |
| Drag with physics on release | `drag` + `dragTransition` / `springs.release` |
| Drag-to-reorder list | `Reorder.Group` + `Reorder.Item` (dnd kit for complex systems) |
| Dismiss on drag | `drag="y"` + `onDragEnd` offset **and** velocity check |
| Swipe left/right | `drag="x"` + `onDragEnd` offset and velocity check |
| Long press | `useLongPress` hook |
| Value smoothed over time | `useSpring` |
| Value derived from another value | `useTransform` |
| Multi-step sequence | `useAnimate` with `async/await` |
| One-shot imperative animation | `animate()` from `motion` |
| Text word by word | Stagger on `inline-block` spans |
| SVG draw-on | `pathLength` 0 -> 1 |
| SVG morph | `d` tween (equal path command counts) |
| Circular progress | `strokeDashoffset` tween |

| | `useSpring` | `transition: springs.*` |
| --- | --- | --- |
| Use for | Pointer-tracked, continuous values | Discrete state changes |
| Updates | Each frame | On state change |
| Interrupt | Continues from current velocity | Starts from current value |

### Motion values and `useAnimate`

```tsx
const x = useMotionValue(0)
const opacity = useTransform(x, [-200, 0, 200], [0, 1, 0])  // no setState, no re-render
```

```tsx
const [scope, animate] = useAnimate()

async function play() {
  await animate(".step-1", { opacity: 1 }, { duration: motionTokens.duration.normal })
  await animate(".step-2", { x: 0 }, { duration: motionTokens.duration.slow })
  animate(".step-3", { scale: 1 }, { duration: motionTokens.duration.normal })  // no await
}

return <div ref={scope}>...</div>
```

- Attach the `scope` ref to a mounted element. Call `animate()` only after mount.
- A new `animate()` call on the same element stops the previous one.
- Create motion values with `useMotionValue`, never `new MotionValue()` in render.

### Draggable card

```tsx
<motion.div
  drag
  dragConstraints={{ left: -100, right: 100, top: -100, bottom: 100 }}
  dragElastic={0.1}
  whileDrag={{ scale: motionTokens.scale.lift }}
  dragTransition={{ bounceStiffness: 300, bounceDamping: 30 }}
/>
```

### Drag-to-dismiss sheet

```tsx
"use client"
import { motion, useMotionValue, useTransform } from "motion/react"

const DISMISS_OFFSET = 120   // px
const DISMISS_VELOCITY = 500 // px/s, tune on real devices

export function BottomSheet({ onClose }: { onClose: () => void }) {
  const y = useMotionValue(0)
  const opacity = useTransform(y, [0, 200], [1, 0])
  return (
    <motion.div
      drag="y"
      dragConstraints={{ top: 0 }}
      dragElastic={{ top: 0.1, bottom: 0.5 }}  // rubber-band, no hard stop
      style={{ y, opacity }}
      onDragEnd={(_, info) => {
        if (info.offset.y > DISMISS_OFFSET || info.velocity.y > DISMISS_VELOCITY) onClose()
      }}
    />
  )
}
```

- Make thresholds explicit. Combine offset and velocity; do not use velocity alone.
- Test drag on real touch devices, not only with a mouse.
- For velocity handoff, momentum projection, and rubber-band math, see parent §6.C-G.

### Swipe detection

```tsx
const OFFSET_THRESHOLD = 50
const VELOCITY_THRESHOLD = 300

<motion.div
  drag="x"
  dragConstraints={{ left: 0, right: 0 }}
  onDragEnd={(_, info) => {
    if (info.offset.x > OFFSET_THRESHOLD || info.velocity.x > VELOCITY_THRESHOLD) onSwipeRight()
    else if (info.offset.x < -OFFSET_THRESHOLD || info.velocity.x < -VELOCITY_THRESHOLD) onSwipeLeft()
  }}
/>
```

### Reorderable list

```tsx
"use client"
import { useState } from "react"
import { Reorder } from "motion/react"

export function SortableList({ initialItems }: { initialItems: { id: string; label: string }[] }) {
  const [items, setItems] = useState(initialItems)
  return (
    <Reorder.Group axis="y" values={items} onReorder={setItems}>
      {items.map((item) => (
        <Reorder.Item key={item.id} value={item}>{item.label}</Reorder.Item>
      ))}
    </Reorder.Group>
  )
}
```

Give reorderable lists a keyboard alternative (move up/down buttons).

### Long press

```tsx
import { useEffect, useRef } from "react"

export function useLongPress(callback: () => void, ms = 600) {
  const timer = useRef<ReturnType<typeof setTimeout>>()
  const clear = () => clearTimeout(timer.current)
  useEffect(() => clear, [])
  return {
    onPointerDown: () => { timer.current = setTimeout(callback, ms) },
    onPointerUp: clear,
    onPointerLeave: clear,
    onPointerCancel: clear,
  }
}
```

### Word-by-word reveal

```tsx
export function AnimatedText({ text }: { text: string }) {
  return (
    <motion.p
      aria-label={text}
      variants={{ visible: { transition: { staggerChildren: motionTokens.stagger.normal } } }}
      initial="hidden"
      animate="visible"
    >
      {text.split(" ").map((word, i) => (
        <motion.span
          key={i}
          aria-hidden
          className="mr-1 inline-block"
          variants={{
            hidden: { opacity: 0, y: 12 },
            visible: { opacity: 1, y: 0, transition: springs.move },
          }}
        >
          {word}
        </motion.span>
      ))}
    </motion.p>
  )
}
```

### Number counter

Update the DOM directly, not React state. Use `tabular-nums` so the width does not change. For production, `NumberFlow` is an option (parent §13).

```tsx
"use client"
import { useEffect, useRef } from "react"
import { animate } from "motion"

export function Counter({ to }: { to: number }) {
  const node = useRef<HTMLSpanElement>(null)
  useEffect(() => {
    const controls = animate(0, to, {
      duration: motionTokens.duration.story,
      ease: motionTokens.easing.out,
      onUpdate: (v) => { if (node.current) node.current.textContent = Math.round(v).toString() },
    })
    return () => controls.stop()
  }, [to])
  return <span ref={node} className="tabular-nums" />
}
```

### SVG path draw-on and progress ring

```tsx
<motion.path
  d="M 0 100 Q 50 0 100 100"
  initial={{ pathLength: 0, opacity: 0 }}
  animate={{ pathLength: 1, opacity: 1 }}
  transition={{ duration: motionTokens.duration.slow, ease: motionTokens.easing.out }}
/>
```

```tsx
const R = 40
const CIRCUMFERENCE = 2 * Math.PI * R

export function ProgressRing({ progress }: { progress: number }) {
  const value = Math.min(100, Math.max(0, progress))
  return (
    <svg width="100" height="100" viewBox="0 0 100 100" role="img" aria-label={`${value}%`}>
      <circle cx="50" cy="50" r={R} fill="none" stroke="var(--track)" strokeWidth="8" />
      <motion.circle
        cx="50" cy="50" r={R} fill="none" stroke="var(--accent)" strokeWidth="8" strokeLinecap="round"
        strokeDasharray={CIRCUMFERENCE}
        animate={{ strokeDashoffset: CIRCUMFERENCE - (value / 100) * CIRCUMFERENCE }}
        transition={{ duration: motionTokens.duration.normal, ease: motionTokens.easing.out }}
        style={{ rotate: -90, transformOrigin: "center" }}
      />
    </svg>
  )
}
```

SVG morphing needs equal path command counts. Different structures snap instead of interpolate.

### Scroll-linked reveal hook

```tsx
"use client"
import { useRef } from "react"
import { useScroll, useTransform } from "motion/react"

export function useScrollReveal() {
  const ref = useRef<HTMLElement>(null)
  const { scrollYProgress } = useScroll({ target: ref, offset: ["start end", "end start"] })
  const opacity = useTransform(scrollYProgress, [0, 0.3], [0, 1])
  const y = useTransform(scrollYProgress, [0, 0.3], [motionTokens.distance.lg, 0])
  return { ref, style: { opacity, y } }
}
```

### Shimmer skeleton (pauses on hidden tab)

```tsx
"use client"
import { useEffect } from "react"
import { motion, useAnimationControls } from "motion/react"

export function ShimmerSkeleton({ className = "" }: { className?: string }) {
  const controls = useAnimationControls()
  useEffect(() => {
    const play = () =>
      controls.start({
        x: ["-100%", "100%"],
        transition: { repeat: Infinity, duration: 1.2, ease: motionTokens.easing.linear },
      })
    const onVisibility = () => (document.visibilityState === "hidden" ? controls.stop() : void play())
    void play()
    document.addEventListener("visibilitychange", onVisibility)
    return () => {
      controls.stop()
      document.removeEventListener("visibilitychange", onVisibility)
    }
  }, [controls])

  return (
    <div className={`relative overflow-hidden rounded bg-gray-200 ${className}`} aria-hidden>
      <motion.div
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/60 to-transparent"
        initial={{ x: "-100%" }}
        animate={controls}
      />
    </div>
  )
}
```

Make skeletons the same shape as the final layout (parent §4.5).

### Button loading state

```tsx
export function LoadingButton({ loading, label, onClick }: { loading: boolean; label: string; onClick: () => void }) {
  return (
    <motion.button
      onClick={onClick}
      disabled={loading}
      aria-busy={loading}
      animate={{ opacity: loading ? 0.7 : 1 }}
      whileTap={loading ? undefined : { scale: motionTokens.scale.press }}
      transition={springs.ui}
    >
      <AnimatePresence mode="wait" initial={false}>
        <motion.span
          key={loading ? "loading" : "label"}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: motionTokens.duration.fast }}
        >
          {loading ? "Saving" : label}
        </motion.span>
      </AnimatePresence>
    </motion.button>
  )
}
```

Keep the button width stable when the label changes (set a `min-width`).

## Not allowed here

These conflict with the parent rules, so this file does not include them:
- Custom cursors and cursor followers (parent §10).
- Decorative or status pulse dots (parent §10).
- Bouncy springs for state changes (parent §6.B allows bounce only after momentum gestures).
- Hover scale-up on buttons as the default feedback (use the press scale).

## Anti-patterns

| Anti-pattern | Fix |
| --- | --- |
| `import { motion } from "framer-motion"` | `motion/react` |
| `initial={{ opacity: 0 }}` on an SSR component | Mount guard |
| No `useReducedMotion` check | `useSafeMotion` |
| `animate={{ width: "100%" }}` | `scaleX` |
| Inline `duration`, `stiffness`, `damping` | Token file |
| No `"use client"` | Add it at the top of the file |
| `navigator` at module level | `typeof navigator !== "undefined"` guard |
| `AnimatePresence` child without `key` | Stable `key` on the direct child |
| `initial` + `animate` without `exit` | Define all three |
| Page transition without `mode="wait"` | Add `mode="wait"` |
| `layout` on a 50-item list | `mode="popLayout"` or explicit transforms |
| `staggerChildren: 0.2` | 0.03-0.08 |
| `whileInView` without `once: true` | Add `viewport={{ once: true }}` |
| `repeat: Infinity` without pause | `visibilitychange` listener |
| `onDragEnd` checks only offset or only velocity | Check both |
| `useEffect` without cleanup | Return `removeEventListener` / `controls.stop` |
| SVG morph between different command structures | Normalize the path commands |

## Related skills

- [`design`](../SKILL.md) §5-§9 - when to animate, easing, durations, springs, gestures, reduced motion.
- [`immersive-web`](immersive-web.md) - GSAP ScrollTrigger, Three.js, WebGL.
- [`make-interfaces-feel-better`](make-interfaces-feel-better.md) - motion polish details.
- [`frontend-development`](../../frontend-development/SKILL.md) - React/Next.js structure.
