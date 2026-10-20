---
name: manim
description: "Creates mathematical animations and educational videos with Manim Community Edition, including scenes, mobjects, LaTeX, and rendering workflows. Use when writing Manim Python code, animating equations, building math visualizations, rendering MP4 or GIF scenes, debugging Manim errors, converting concepts into animated diagrams, or using manim CLI, MathTex, ThreeDScene, ValueTracker, and updaters."
---

# Manim Community – Mathematical Animation Engine

Create programmatic mathematical animations and educational videos with the Manim Community Python library.

## When to use
- You need to animate geometric shapes, graphs, or coordinate systems.
- You want to display LaTeX equations inside an animation.
- You are building a teaching video or visual explanation.
- You require precise control over timing, camera, or 3D objects.

## Core Concepts
- **Scene**: The canvas that holds all objects. Inherit from `Scene` and implement a `construct()` method.
- **Mobject**: Any visual object (shape, text, graph). Examples: `Square()`, `Circle()`, `Tex()`, `MathTex()`.
- **Animation**: A transformation applied to a mobject. Common animations: `Create`, `Write`, `Transform`, `FadeIn`, `FadeOut`.
- **Transform**: Morph one mobject into another, e.g., `Transform(square, circle)`.
- **Camera**: Controls view, zoom, and 3‑D rotation.
- **VGroup**: Container to group multiple mobjects for collective operations.

## Key Features
- Precise positioning and scaling of objects.
- Native LaTeX rendering for equations.
- Large shape library (circles, polygons, arrows, etc.).
- Function graphing and coordinate axes.
- Boolean operations on shapes (union, intersection, subtraction).
- Camera panning, zooming, and 3‑D rotation.
- Fast low‑quality preview and high‑quality final render.
- Integration with Jupyter notebooks and VS Code live preview.

## Quick Start Example
```python
from manim import *

class SquareToCircle(Scene):
    def construct(self):
        # Create a square and set its appearance
        square = Square().set_fill(BLUE, opacity=0.5)
        # Create a circle with a different appearance
        circle = Circle().set_fill(RED, opacity=0.5)
        # Show the square
        self.play(Create(square))
        self.wait(1)
        # Morph square into circle
        self.play(Transform(square, circle))
        self.wait(1)
        # Fade out the result
        self.play(FadeOut(square))
```
Render with:
```
manim -pql script.py SquareToCircle
```
`-p` opens the video after rendering. `-ql` uses low quality for fast preview.

## Command Line Usage
| Flag | Purpose |
|------|---------|
| `-p` | Open the rendered video automatically |
| `-ql` | Low‑quality preview (fast) |
| `-qh` | High‑quality render |
| `-s` | Save the last frame as an image |
| `script.py SceneName` | Render the specified scene |
| `script.py Scene1 Scene2` | Render multiple scenes |

Typical commands:
```bash
# Fast preview
manim -pql script.py MyScene

# High‑quality final video
manim -pqh script.py MyScene

# Export a single frame
manim -s script.py MyScene
```

## Best Practices
- **Inherit from `Scene`** for every animation file.
- **Put all code inside `construct()`**; the method runs once per render.
- **Add mobjects before animating them**; use `self.add(mobject)` if needed.
- **Use `self.play()`** to queue animations; chain multiple animations in one call when they should run together.
- **Preview with low quality** (`-ql`) to iterate quickly.
- **Leverage LaTeX**: use `Tex()` for plain text and `MathTex()` for equations.
- **Group related objects** with `VGroup` to move or transform them as a unit.
- **Name your scenes clearly**; the class name is the identifier used on the command line.
- **Keep code readable**: add comments, use descriptive variable names, and avoid overly long `self.play()` chains.

## Common Pitfalls
- Forgetting to call `self.add(mobject)` before an animation can cause the object not to appear.
- Using high‑quality flags (`-qh`) for every test slows the workflow.
- Overlapping animations without proper timing may produce visual glitches; use `self.wait()` or `lag_ratio` to stagger.
- Rendering large 3‑D scenes without adjusting `camera` settings can lead to slow renders; set `self.camera.frame_width` and `self.camera.frame_height` appropriately.
- Not clearing temporary files; delete the `media/` folder periodically to free space.

## Checklist
- [ ] Create a Python file ending with `.py`.
- [ ] Define a class that inherits from `Scene`.
- [ ] Implement a `construct()` method.
- [ ] Instantiate required mobjects inside `construct()`.
- [ ] Add mobjects to the scene before animating.
- [ ] Use `self.play()` for each animation step.
- [ ] Insert `self.wait()` where timing adjustments are needed.
- [ ] Test with `manim -pql` for fast preview.
- [ ] Render final video with `manim -pqh`.
- [ ] Export frames with `-s` if needed.

## Resources
- Documentation: https://docs.manim.community/
- GitHub repository: https://github.com/ManimCommunity/manim
- Example gallery: https://docs.manim.community/en/stable/examples.html

## Related skills

Load these when the task spans more than this skill.

- [`scientific-figures`](../scientific-figures/SKILL.md) — Create publication-ready scientific figures with matplotlib, seaborn, and Plotly. Use for journal plots, multi…
- [`motion-canvas`](../motion-canvas/SKILL.md) — Set up and troubleshoot Motion Canvas projects, write TypeScript animation scenes with generator functions, si…
- [`remotion`](../remotion/SKILL.md) — Comprehensive guide for Remotion - programmatic video creation in React. Covers compositions, frame-based anim…
- [`diagrams`](../diagrams/SKILL.md) — Skill for creating, editing, converting, and reviewing diagram files. Handles draw.io .drawio XML editing and…
- [`scientific-slides`](../scientific-slides/SKILL.md) — Generates scientific presentation slides (PDF, PowerPoint, or LaTeX Beamer) using AI‑generated images, provide…
- [`generative-art`](../generative-art/SKILL.md) — Create generative art through a two-phase process: first define an algorithmic/visual philosophy (.md), then e…
